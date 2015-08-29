require 'analysis/phase'
require 'analysis/helpers'
require 'analysis/trans/vhdl'

module Phases
  class GenVHDL < Phase

    def self.run s
      puts "VHDL Generation started"

      puts "Generating BBs"
      select_bbs(s).each do |bb|

        puts "order analysing bb: #{bb[:func]}@#{bb[:addr].to_s(16)}"
        self.analyse_bb_reg_dependencies(bb)

        dump_bb_code(bb)

        puts "parallelizing bb: #{bb[:func]}@#{bb[:addr]}: #{bb[:code].count} lines"
        unless (bb[:code].count < s[:options][:num_parallel]) || s[:options][:do_all_blocks] then
          puts "skipping processing due to size"
          next
        end

        self.parallelize_bb(bb)
        puts "parallelized into #{bb[:par_code].count} pars"

        puts "generating bb: #{bb[:func]}@#{bb[:addr]}"
        self.translate_bb_pars(bb)

        self.print_translated_bb(bb)
      end

      puts "Generating Loops"
      s[:loops].each do |loop|
        puts "working on loop: #{loop[:func]} #{loop[:start].to_s(16)}-#{loop[:end].to_s(16)}"

        if loop[:structured].nil? then
          puts "skipping loop due to unknown structure"
          next
        end

        self.translate_loop(loop)

        pp loop

        self.print_translated_loop(loop)
      end

      puts "VHDL Generation concluded"

      return s
    end

    private
    def self.pars_r(line, seen_lines)
      lines = []
      line[:deps].each do |dep|
        ret = pars_r(dep, seen_lines)
        lines.concat(ret[:lines])
        seen_lines.concat(ret[:seen_lines]).uniq!
      end
      return {lines: lines.push(strip_line(line)), seen_lines: seen_lines.push(line[:addr]).uniq}
    end

    def self.analyse_bb_reg_dependencies(bb)
      #records where each reg was last written to
      used_regs = {}

      bb[:code].each do |line|
        line[:deps] = []
        line[:deps_lines] = []

        #check for deps
        line[:args].each_with_index do |arg, i|
          if arg[0] == 'r' then
            #GP register

            #don't generate deps for the first register arg, as this is always rt/rd
            if (i > 0) && (used_regs.include? arg) then
              #this line depends on used_regs[arg], unless that is us, or we already depend on it
              unless (line[:deps_lines].include? used_regs[arg][:addr]) || (line[:addr] == used_regs[arg][:addr]) then
                line[:deps].push used_regs[arg]
                line[:deps_lines].push used_regs[arg][:addr]
              end
            end

            #only update first register arg, or this is the last use of this register as an argument
            if (line[:args].count(arg) == 1 && i == 0) ||
               (line[:args].count(arg) > 1 && !(line[:args][i+1, line[:args].length].include? arg)) then
              used_regs[arg] = line
            end
          else
            #immediate argument, array of registers, etc
          end
        end
      end
    end

    def self.parallelize_bb(bb)
      seen_lines = []
      bb[:par_code] = []

      bb[:code].reverse_each do |line|
        unless seen_lines.include? line[:addr] then
          ret = pars_r(line, seen_lines)
          seen_lines.concat(ret[:seen_lines]).uniq!
          bb[:par_code].push ret[:lines]
        end
      end
    end

    def self.translate_bb_pars(bb)
      #statement transliteration
      bb[:trans_code] = []
      bb[:trans_signals] = []

      #TODO: optimize the bodging!
      par_regs = []
      bb[:par_code].each do |par|
        begin
          par_trans = []

          Trans::treg_newpar
          par_trans.concat Trans::treg_in(par)

          #transliterate
          par.each_index do |l_i|
            l = par[l_i]
            par_trans.concat Trans::trans(l)

            par_trans.concat Trans::treg_post_line
          end

          par_trans.concat Trans::treg_out(par, par_trans)

          par_regs.concat Trans::treg_used

          bb[:trans_code].push par_trans
        rescue
          puts "Unable to translate par: #{$!}"
        end
      end

      bb[:trans_used_regs] = par_regs
    end

    def self.print_translated_bb(bb)
      #generate needed signals:
      bb[:trans_signals].push "variable #{($added_temps + bb[:trans_used_regs]).join(", ")} : std_logic_vector(31 downto 0);"

      #TODO: put in a file, not STDOUT
      #dump the thing
      puts "#"*70
      puts "#{bb[:func]}@#{bb[:addr].to_s(16)}[#{bb[:code][0][:addr].to_s(16)}:#{bb[:code][-1][:addr].to_s(16)}]->"
      puts "A #{bb[:arith_num]} #{bb[:arith_seq]} #{bb[:arith_num_p]} #{bb[:arith_seq_p]}"
      puts "S #{bb[:simd_arith_num]} #{bb[:simd_arith_seq]} #{bb[:simd_num_p]} #{bb[:simd_seq_p]}" if bb[:has_simd]
      print "L> "
      bb[:code].each do |line|
        print "#{line[:instr]}, "
      end
      puts ""
      puts "pars: #{bb[:par_code].count}"
      bb[:par_code].each_with_index do |lines, i|
        print "#{i}> "
        lines.each do |line|
          print "#{line[:instr]}, "
        end
        puts ""
      end
      puts "trans: "
      puts bb[:trans_signals]
      puts "-------------"
      bb[:trans_code].each_with_index do |lines, i|
        puts "trans #{i}>"
        lines.each { |l| puts l }
      end
      puts "#"*70
    end

    def self.translate_loop(loop)
      loop[:trans] = {}
      loop[:trans][:name] = "loop_#{loop[:start].to_s(16)}"
      loop[:trans][:sensitive_signals] = []

      Trans::treg_newpar

      #translate COUNTER_INIT
      loop[:trans][:counter_init] = []
      loop[:structured][:counter_init].each do |line|
        loop[:trans][:counter_init].concat Trans::trans(line)
        Trans::treg_post_line
      end

      #translate COUNTER_INCREMENT to arithmetic operation
      loop[:trans][:counter_increment] = []
      loop[:structured][:counter].each do |line|
        loop[:trans][:counter_increment].concat Trans::trans(line)
        Trans::treg_post_line
      end

      #add COUNTER_FIXUP after COUNTER_INCREMENT
      #this is because the translate behaviour will generate a line like
      #'new_counter = counter + 1'
      #but we need 'counter = counter + 1', so lets add a line like
      #'counter = new_counter' manually here
      relevant_regs = Trans::treg_used.select { |r| r.start_with?(loop[:structured][:counter_reg]) }.sort
      loop[:trans][:counter_fixup] = "#{relevant_regs.first} := #{relevant_regs.last};"

      #translate LOOP_BODY
      loop[:trans][:body] = []
      loop[:structured][:body].each do |line|
        loop[:trans][:body].concat Trans::trans(line)
        Trans::treg_post_line
      end

      #translate condition
      cond_base = instr_base(loop[:structured][:comparison][:instr])
      branch_base = instr_base(loop[:structured][:branch][:instr])
      negate = false
      case cond_base
        when "cmp"
        when "cmn"
          negate = !negate
        when "sub"
        else
          puts "unknown comparison condition #{cond_base}, skipping loop"
          return
      end
      case branch_base
        when "bne"
        when "beq"
          negate = !negate
        else
          puts "unknown branch #{branch_base}, skipping loop"
          return
      end
      loop[:trans][:condition] = "#{loop[:structured][:comparison][:args][0]} = #{loop[:structured][:comparison][:args][1]}"
      loop[:trans][:condition] = "not (#{loop[:trans][:condition]})" if negate

      loop[:trans][:temps] = Trans::treg_used
    end

    def self.print_translated_loop(loop)
      unless loop[:trans][:sensitive_signals].empty?
        sensitivity_list = ", #{loop[:trans][:sensitive_signals].join(", ")}"
      end

      puts "#"*70
      puts "#{loop[:trans][:name]}_proc : process(clk, reset#{sensitivity_list})"
      puts "variable #{loop[:trans][:temps].join(", ")} : std_logic_vector(31 downto 0)";
      puts "variable loop_finished : std_logic;"
      puts "begin"
      puts "  if clk = '1' and clk'event then"
      puts "    if reset = '1' then"
      puts "      loop_finished := '0';"
      loop[:trans][:counter_init].each do |line|
        puts " "*6 + line
      end
      puts "    elif loop_finished = '1' then"
      #DO NOTHING ELSE
      puts "    else"
      puts "      if #{loop[:trans][:condition]} then"
      puts "        loop_finished := '1';"
      puts "      else"
      puts "-- body:"
      loop[:trans][:body].each do |line|
        puts " "*8 + line
      end
      puts "-- counter:"
      loop[:trans][:counter_increment].each do |line|
        puts " "*8 + line
      end
      puts " "*8 + loop[:trans][:counter_fixup]
      puts "      end if;"
      puts "    end if;"
      puts "  end if;"
      puts "end process;"
      puts "#"*70
    end

  end
end
