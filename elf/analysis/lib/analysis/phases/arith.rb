require 'analysis/phase'
require 'analysis/arm'

module Phases
  class Arith < Phase

    def self.run s
      puts "Starting arithmetic analysis"

      s[:bbs].each do |bb|
        puts "analysing bb: #{bb[:func]}@#{bb[:addr].to_s(16)}"

        arith_num = 0
        arith_seq = 0
        max_arith_seq = 0

        bb[:code].each do |line|
          if ARM::ARITH_INSNS.include? instr_base(line[:instr]) then
            arith_num = arith_num + 1
            arith_seq = arith_seq + 1
          else
            max_arith_seq = arith_seq if arith_seq > max_arith_seq
            arith_seq = 0
          end
        end

        bb[:arith_num] = arith_num
        bb[:arith_seq] = max_arith_seq
        bb[:arith_num_p] = (bb[:size] > 1) ? arith_num.to_f / (bb[:size]-1) * 100 : 0
        bb[:arith_seq_p] = (bb[:size] > 1) ? max_arith_seq.to_f / (bb[:size]-1) * 100 : 0
      end

      puts "Arithmetic analysis concluded"
      puts "-"*60

      return s
    end
  end
end
