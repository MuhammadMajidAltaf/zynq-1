require 'analysis/arm'

def strip_line(line)
  return {addr: line[:addr], raw: line[:raw], instr: line[:instr], args: line[:args]}
end

def pars_r(line, seen_lines)
  lines = []
  line[:deps].each do |dep|
    ret = pars_r(dep, seen_lines)
    lines.concat(ret[:lines])
    seen_lines.concat(ret[:seen_lines]).uniq!
  end
  return {lines: lines.push(strip_line(line)), seen_lines: seen_lines.push(line[:addr]).uniq}
end

def dump_bb(bbs, func)
  bbs.each do |bb|
    pp bb if bb[:func] == func
  end
end

def instr_base(instr)
  base = instr.split(".")[0]
  if base[-1] == "s" then
    #possibly want to remove this s (if outside an IT block - but I can't tell that from here...)
    test_base = base[0,base.length-1]
    if ARM::ALL_ARITH_INSNS.include? test_base then
      base = test_base
    end
  end
  return base
end

def select_bbs(s)
  s[:bbs].sort_by{|bb| bb[:prof][:time_p] }.reverse.select do |bb|
    ((bb[:arith_seq] > s[:options][:min_num_arith]) || (bb[:has_simd] && (bb[:simd_arith_seq] > s[:options][:min_num_arith]))) && (bb[:size] > s[:options][:min_length]) && (bb[:prof][:time_p] > s[:options][:min_runtime_percentage])
  end.take(s[:options][:num_taken]).reverse
end
