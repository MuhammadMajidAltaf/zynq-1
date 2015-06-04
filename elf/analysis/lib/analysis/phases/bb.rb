require 'analysis/phase'
require 'analysis/arm'

module Phases
  class BasicBlock < Phase

    def self.run s
      puts "Starting Basic Block analysis"
      bbs = []
      funcs = {}
      cur_block = []

      s[:sections][".text"].each do |func, data|
        puts "analysing func: #{func}@#{data[:addr].to_s(16)}"

        data[:code].each do |line|
          cur_block.push line

          base = instr_base(line[:instr])
          if ARM::BRANCH_INSNS.include?(base) || ARM::BRANCH_IT.include?(base) || ARM::BRANCH_SUFFIXES.include?(base[-2,2]) || ARM::ALL_LDST_INSNS.include?(base)  then
            #Was a non-basic thing
            func_base = func.split(".")[0]
            prof = (s[:flat_prof].include? func_base) ? s[:flat_prof][func_base] : {time_p: 0, time_cum: 0, time_sef: 0, calls:0 , call_self: 0, call_total: 0}
            b = {func: func, addr: data[:addr], size: cur_block.count, code: cur_block.clone, prof: prof}
            funcs[func] = [] unless funcs.include? func
            funcs[func].push b
            bbs.push b
            cur_block = []
          end
        end
      end

      bbs.sort_by! { |bb| bb[:size] }.reverse!

      puts "#{bbs.count} Basic Blocks completed"
      puts "-"*60

      new = {bbs: bbs}
      return s.merge new
    end
  end
end
