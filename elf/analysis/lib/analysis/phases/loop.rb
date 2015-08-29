require 'analysis/phase'
require 'analysis/arm'

#Note: I apologise to whoever reads this file for some of the short variable naming used

module Phases
  class Loops < Phase

    def self.run s
      puts "Starting Loop analysis"

      loops = []

      s[:sections][".text"].each do |func, data|
        puts "analysing func: #{func}@#{data[:addr].to_s(16)}"

        cur_block = []

        data[:code].each do |line|
          cur_block.push line

          base = instr_base(line[:instr])
          if ARM::BRANCH_INSNS.include?(base) || ARM::BRANCH_IT.include?(base) || ARM::BRANCH_SUFFIXES.include?(base[-2,2]) then
            #Found a branch. Check if target is behind PC.
            pc = line[:addr]

            base = line[:branch][:base]
            offset = line[:branch][:offset]
            absolute = line[:branch][:absolute]

            unless base.nil? and offset.nil?
              #lookup location of target
              addr = s[:sections][".text"][base][:addr] + offset
              if addr != absolute then
                #Something has gone wrong with either the read-in, or the symbol location calculation
                raise "Absolute address not equal to calculated address: 0x#{absolute.to_i(16)} != 0x#{addr.to_i(16)}"
              end

              if absolute < pc then
                #is a loop! (probably)

                #find bbs between addr and pc
                loop_bbs = []
                s[:funcs][base].each do |bb|
                  loop_bbs.push bb if ((bb[:addr] <= addr) && (bb[:addr] + bb[:size]*4 > addr)) || ((bb[:addr] >= addr) && (bb[:addr] + bb[:size]*4 >= pc))
                end

                #define the inital form of the loop data
                l = {start: addr, end: pc, func: base, bbs: loop_bbs.sort_by { |b| b[:addr] }}

                #try to find the interesting parts of the loop: initialization, loop counter, loop body
                #TODO: makes some single instruction assumptions

                puts "checking for known loop structure"
                last_cmp = self.find_last_cmp(l)
                unless last_cmp.nil? then
                  puts "found last comparison of #{last_cmp[:instr]} at #{last_cmp[:addr].to_s(16)}"

                  #TODO: assumes first arg of cmp will be correct - assumes compiler generated
                  counter_reg = last_cmp[:args][0]
                  #try to find the loop counter arithmetic operations
                  counter = [self.find_first_constant_arith_with_reg(l, counter_reg)]
                  unless counter.length == 0 || counter[0].nil? then
                    puts "found loop counter expression starting #{counter[0][:instr]} at #{counter[0][:addr].to_s(16)}"

                    #try to find the initialization for this counter
                    init = [self.find_last_mov_with_reg_before_loop(l, counter_reg)]
                    unless init.length == 0 || init[0].nil? then
                      puts "found initialization starting #{init[0][:instr]} at #{init[0][:addr].to_s(16)}"

                      #Determine loop body based on this information
                      body_init = []
                      body = []

                      l[:bbs].each do |bb|
                        bb[:code].each do |ll|
                          if ll[:addr] < l[:start] then
                            body_init.push ll if ll != init
                          else
                            unless counter.include?(ll) ||
                                   init.include?(ll) ||
                                   line == ll || last_cmp == ll then
                              body.push ll
                            end
                          end
                        end
                      end

                      #Found all expected items, record in the loop data blob
                      l[:structured] = {counter_reg: counter_reg,
                                        counter: counter,
                                        counter_init: init,
                                        branch: line,
                                        comparison: last_cmp,
                                        body: body}
                    end
                  end
                end

                #push the final loop data to the global list
                loops.push l
              end
            end

            cur_block = []
          end
        end
      end

      pp loops

      puts "Loop analysis concluded - found #{loops.count} loops"
      puts "-"*60

      new = {loops: loops}
      return s.merge new
    end

    private
    def self.find_last_cmp(lp)
      lp[:bbs].reverse.each do |bb|
        bb[:code].reverse.each do |line|
          #Might be a cmp instruction, might be a conditional update from ADDS/SUBS etc.
          if (ARM::CMP_INSNS.include?(instr_base(line[:instr]))) ||
            (ARM::ARITH_INSNS.include?(instr_base(line[:instr])) && (line[:instr][-1] == ARM::COND_SUFFIX)) then
            return line
          end
        end
      end
      return nil
    end

    def self.find_first_constant_arith_with_reg(lp, reg)
      lp[:bbs].each do |bb|
        bb[:code].each do |line|
          next if line[:addr] < lp[:start]

          if ARM::SIMPLE_ARITH_INSNS.include? instr_base(line[:instr]) then
            if line[:args][0] == reg and line[:args][1] == reg then
              #Arithmetic instruction, destination and source register matches
              #Need to check if it performs a constant operation
              #Forms: (rx, #imm) or (rx, Op2)
              if line[:args][2][0] == "#" or line[:args][2][0] == "r" then
                #rx, #imm form or rx, register form
                return line
              end
            end
          end
        end
      end
      return nil
    end

    def self.find_last_mov_with_reg_before_loop(lp, reg)
      lp[:bbs].each do |bb|
        bb[:code].reverse.each do |line|
          next if line[:addr] >= lp[:start]

          if ARM::MOV_INSNS.include? instr_base(line[:instr]) then
            if line[:args][0] == reg then
              #Either imm or Op2 setup, don't care here for new with either
              return line
            end
          end
        end
      end
      return nil
    end

  end
end
