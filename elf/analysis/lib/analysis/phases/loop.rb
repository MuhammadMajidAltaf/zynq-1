require 'analysis/phase'
require 'analysis/arm'

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

                l = {start: addr, end: pc, func: base, bbs: loop_bbs}
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
  end
end
