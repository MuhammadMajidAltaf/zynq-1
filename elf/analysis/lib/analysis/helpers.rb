require 'analysis/arm'

def strip_line(line)
  return {addr: line[:addr], raw: line[:raw], instr: line[:instr], args: line[:args]}
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
  #Do all override
  return s[:bbs] if s[:options][:do_all_blocks]

  unless s[:options][:gprof_file].nil? then
    #Have profiling data
    return s[:bbs].sort_by{|bb| bb[:prof][:time_p] }.reverse.select do |bb|
      ((bb[:arith_seq] > s[:options][:min_num_arith]) || (bb[:has_simd] && (bb[:simd_arith_seq] > s[:options][:min_num_arith]))) && (bb[:size] > s[:options][:min_length]) && (bb[:prof][:time_p] > s[:options][:min_runtime_percentage])
    end.take(s[:options][:num_taken]).reverse
  end

  #Just have the calculated statistics
  return s[:bbs] do |bb|
    ((bb[:arith_seq] > s[:options][:min_num_arith]) || (bb[:has_simd] && (bb[:simd_arith_seq] > s[:options][:min_num_arith]))) && (bb[:size] > s[:options][:min_length])
  end.take(s[:options][:num_taken]).reverse
end

def dump_bb_code(bb)
  puts '<'*50
  bb[:code].each do |line|
    puts '='*30
    puts "l: #{line[:addr].to_s(16)}: #{line[:instr]} #{line[:args]}"
    puts "d: #{line[:deps].join(",")}"
    puts "dl: #{line[:deps_lines].map{|dl| dl.to_s(16)}.join(",")}"
  end
  puts '>'*50
end

def is_reg(name)
  return (name[0] == 'r') || (name == "pc") || (name == "ip") || (name == "sp")
end
