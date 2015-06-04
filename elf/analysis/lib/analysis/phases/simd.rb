require 'analysis/phase'
require 'analysis/arm'

module Phases
  class SIMD < Phase

    def self.run s
      puts "Starting SIMD analysis"

      s[:bbs].each do |bb|
        puts "analysing bb: #{bb[:func]}@#{bb[:addr].to_s(16)}"

        bb[:has_simd] = false
        arith_num = 0
        arith_seq = 0
        max_arith_seq = 0

        bb[:code].each do |line|
          if ARM::SIMD_ARITH_INSNS.include? instr_base(line[:instr]) then
            bb[:has_simd] = true
            arith_num = arith_num + 1
            arith_seq = arith_seq + 1
          else
            max_arith_seq = arith_seq if arith_seq > max_arith_seq
            arith_seq = 0
          end
        end

        bb[:simd_arith_num] = arith_num
        bb[:simd_arith_seq] = max_arith_seq
        bb[:simd_num_p] = (bb[:size] > 1) ? arith_num.to_f / (bb[:size]-1) * 100 : 0
        bb[:simd_seq_p] = (bb[:size] > 1) ? max_arith_seq.to_f / (bb[:size] - 1) * 100 : 0
      end

      bbs_simd = s[:bbs].select { |bb| bb[:has_simd] }
      puts "SIMD analysis conclude - found #{bbs_simd.count} BBs"
      puts "-"*60

      return s
    end
  end
end
