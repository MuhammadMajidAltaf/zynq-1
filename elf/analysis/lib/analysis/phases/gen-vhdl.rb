require 'analysis/phase'
require 'analysis/helpers'
require 'analysis/trans/vhdl'

module Phases
  class GenVHDL < Phase

    def self.run s
      puts "VHDL Generation started"

      select_bbs(s).each do |bb|

        puts "order analysing bb: #{bb[:func]}@#{bb[:addr].to_s(16)}"

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

        puts '<'*50
        bb[:code].each do |line|
          puts '='*30
          puts "l: #{line[:addr].to_s(16)}: #{line[:instr]} #{line[:args]}"
          puts "d: #{line[:deps].join(",")}"
          puts "dl: #{line[:deps_lines].map{|dl| dl.to_s(16)}.join(",")}"
        end
        puts '>'*50

        puts "parallelizing bb: #{bb[:func]}@#{bb[:addr]}: #{bb[:code].count} lines"

        seen_lines = []
        bb[:par_code] = []

        if bb[:code].count < s[:options][:num_parallel] then
          bb[:code].reverse_each do |line|
            unless seen_lines.include? line[:addr] then
              ret = pars_r(line, seen_lines)
              seen_lines.concat(ret[:seen_lines]).uniq!
              bb[:par_code].push ret[:lines]
            end
          end

          puts "parallelized into #{bb[:par_code].count} pars"
        else
          puts "skipping processing due to size"
        end

        puts "generating bb: #{bb[:func]}@#{bb[:addr]}"
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
              trans_lines = [Trans::trans(l)].flatten.reject{|l| l.nil?}
              par_trans.concat trans_lines

              par_trans.concat Trans::treg_post_line(par, trans_lines, l, l_i)
            end

            par_trans.concat Trans::treg_out(par, par_trans)

            par_regs.concat Trans::treg_used

            bb[:trans_code].push par_trans
          rescue
            puts "Unable to translate par: #{$!}"
          end
        end

        #generate needed signals:
        bb[:trans_signals].push "variable #{($added_temps + par_regs).join(", ")} : std_logic_vector(31 downto 0);"

        #TODO: put in a file, not STDOUT
        #dump the thing
        puts "#"*70
        puts "#{bb[:func]}@#{bb[:addr].to_s(16)}[#{bb[:code][0][:addr].to_s(16)}:#{bb[:code][-1][:addr].to_s(16)}]->"
        puts "A #{bb[:arith_num]} #{bb[:arith_seq]} #{bb[:arith_num_p]} #{bb[:arith_seq_p]}"
        puts "S #{bb[:simd_arith_num]} #{bb[:simd_arith_seq]} #{bb[:simd_num_p]} #{bb[:simd_seq_p]}" if bb[:has_simd]
        pp bb[:prof]
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

      puts "VHDL Generation concluded"

      return s
    end
  end
end
