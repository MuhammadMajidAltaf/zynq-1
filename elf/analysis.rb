#!/usr/bin/env ruby
require 'rubygems'
require 'pp'

BRANCH_INSNS = ['bl', 'blx', 'bx', 'cbnz', 'cbz', 'b', 'tbb', 'tbh']
BRANCH_SUFFIXES = ['eq', 'ne', 'cs', 'cc', 'mi', 'pl', 'vs', 'vc', 'hi', 'ls', 'ge', 'lt', 'gt', 'le']
BRANCH_IT = ['it', 'itt', 'ite', 'itt', 'itet' ,'itte', 'itee', 'itttt', 'itett', 'ittet', 'iteet', 'ittte' ,'itete' ,'ittee', 'iteee']

SHIFTS = ['lsl', 'lsr', 'asr', 'ror', 'rrx']

DP_INSNS = ['adc', 'add', 'adr', 'and', 'bic', 'cmn', 'cmp', 'eor', 'mov', 'mvn', 'orn', 'orr', 'rsb', 'rsc', 'sbc', 'sub',] #none: 'teq', 'tst'
SHIFT_INSNS = ['asr', 'lsl', 'lsr', 'ror', 'rrx']
MUL_INSNS = ['mla', 'mls', 'mul', 'smlabb', 'smlabt', 'smlatb', 'mslatt', 'smlad', 'smlal', 'smlalbb', 'smlalbt', 'smlaltb', 'smlaltt', 'smlald', 'smlawb', 'smlawt', 'smlsd', 'smlsld', 'smmla', 'smlls', 'smmul', 'smuad', 'smulbb', 'smulbt', 'smultb', 'smultt', 'smull', 'smulwb', 'smulwt', 'smusd', 'umaal', 'umlal', 'umull']
SAT_INSNS = ['ssat', 'ssat16', 'usat', 'usat16', 'qadd', 'qsub', 'qdadd', 'qdsub']
PACK_INSNS = ['pkh', 'sxtab', 'sxtab16', 'sxtah', 'sxtb', 'sxtb16', 'sxth', 'uxtab', 'uxtab16', 'uxtah', 'uxtb', 'uxtb16', 'uxth']
PAR_INSNS = ['sadd16', 'qadd16', 'shadd16', 'uadd16', 'uqadd16', 'uhadd16', 'sasx', 'qasx', 'shasx', 'uasx', 'uqasx', 'uhasx', 'ssax', 'qsax', 'shsax', 'usax', 'uqsax', 'uhsax', 'ssub16', 'qsub16', 'shsub16', 'usub16', 'uqsub16', 'uhsub16', 'sadd8', 'qadd8', 'shad8', 'uadd8', 'uqadd8', 'uhadd8', 'ssub8', 'qsub8', 'shsub8', 'usub8', 'uqsub8', 'uhsub8']
DIV_INSNS = ['sdiv', 'udiv']
MISC_INSNS = ['bfc', 'bfi', 'clz', 'movt', 'rbit', 'rev', 'rev16', 'revsh', 'sbfx', 'sel', 'ubfx', 'usad8', 'usada8']
LDST_INSNS = ['ldr', 'str', 'ldrt', 'strt', 'ldrex', 'strex', 'strh', 'strht', 'strexh', 'ldrh', 'ldrht', 'ldrexh', 'ldrsh', 'ldrsht', 'strb', 'strbt', 'strexb', 'ldrb', 'ldrbt', 'ldrexb', 'ldrsb', 'ldrsbt', 'ldrd', 'strd', 'ldrexd', 'strexd']
LDSTMUL_INSNS = ['ldm', 'ldmia', 'ldmfd', 'ldmda', 'ldmfa', 'ldmdb', 'ldmea', 'ldmib', 'ldmed', 'pop', 'push', 'stm', 'stmia', 'stmea', 'stmda', 'stmed', 'stmdb', 'stmfd', 'stmib', 'stmfa']

SIMD_LDST_INSNS = ['vldm', 'vldr', 'vstm', 'vstr', 'vdup', 'vmov', 'vmrs', 'vmsr']
SIMD_PAR_INSNS = ['vadd', 'vaddhn', 'vaddl', 'vaddw', 'vhadd', 'vhsub', 'vpadal', 'vpadd', 'vpaddl', 'vraddhn', 'vrhadd', 'vrsubhn', 'vqadd', 'vqsub', 'vsub', 'vsubhn', 'vsubl', 'vsubw']
SIMD_BIT_INSNS = ['vand', 'vbic', 'veor', 'vbif', 'vbit', 'vbsl', 'vmov', 'vmvn', 'vorr', 'vorn']
SIMD_ADV_INSNS = ['vagce', 'vacgt', 'vacle', 'vaclt', 'vceq', 'vcge', 'vcgt', 'vcle'] #none: 'vtst'
SIMD_SHIFT_INSNS = ['vqrshl', 'vqrshrn', 'vqrshrun', 'vqshl', 'vqshlu', 'vqshrn', 'vqshrun', 'vrshl', 'vrshr', 'vrsa', 'vrshn', 'vshl', 'vshll', 'vshr', 'vshrn', 'vsli', 'vsra', 'vsri']
SIMD_MUL_INSNS = ['vmla', 'vmlal', 'vmls', 'vmlsl', 'vmul', 'vmull', 'vfma', 'vfms', 'vqdmlal', 'vqdmlsl', 'vqdmul', 'vqrdmulh', 'vqdmull']
SIMD_MISC_INSNS = ['vaba', 'vabal', 'vabd', 'vabdl', 'vabs', 'vcvt', 'vcls', 'vclz', 'vcnt', 'vdup', 'vext', 'vmovn', 'vmovl', 'vmax', 'vmin', 'vneg', 'vpmax', 'vpmin', 'vrecpe', 'vrecps', 'vrsqrte', 'vrsqrts', 'vrev16', 'vrev32', 'vrev64', 'vqabs', 'vqmovn', 'vqmovun', 'vqneg', 'vswp', 'vtbl', 'vtbx', 'vtrn', 'vuzp', 'vzip']

ARITH_INSNS = DP_INSNS + SHIFT_INSNS + MUL_INSNS + SAT_INSNS + PAR_INSNS + DIV_INSNS + MISC_INSNS
SIMD_ARITH_INSNS = SIMD_PAR_INSNS + SIMD_BIT_INSNS + SIMD_SHIFT_INSNS + SIMD_MUL_INSNS + SIMD_ADV_INSNS + SIMD_MISC_INSNS

# Important magic constants (but not important enough to pass in every time...)
MIN_RUNTIME_PERCENTAGE = 5
MIN_NUM_ARITH = 4
MIN_SIZE = 10
MAX_PARALLEL = 100


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

if ARGV.length < 4 then
  puts "Not enough arguments"
  puts "[objdump-file] [num-take] [stages] [gprof-file]"
  exit
end

DIS_FILE = ARGV[0]
NUM_TAKE = ARGV[1].to_i
STAGES = ARGV[2].split(":")
PROF_FILE = ARGV[3]

#Parse in obj-dump file and extract sections

sections = {}
cur_section = nil
cur_function = nil

#################################
# Read in
#################################

puts "Reading in objdump"

File.open(DIS_FILE, 'r') do |obj|
  obj.each_line do |line|

    if line =~ /Disassembly of section (.*):$/ then
      cur_section = $1.strip
      cur_function = nil
      puts "sec #{cur_section}"
      sections[cur_section] = {} unless sections.key? cur_section
    end

    unless cur_section.nil? then
      if line =~ /^(\d+) <(.*)>:/ then
        #Section/Function header
        addr = $1.to_i(16)
        cur_function = $2
        sections[cur_section][cur_function] = {addr: addr, code: []} unless sections[cur_section].key? cur_function
      end

      unless cur_function.nil? then
        if line =~ /([0-9a-f]+):\t([0-9a-f ]+)\s\t([a-z.,\[\]{}:0-9]+)(\t(.*))?$/ then

          #Line
          #TODO: extend arg parsing to curly-brace expressions
          args = $5.nil? ? [] : $5.split(", ")
          l = { addr: $1, raw: $2, instr: $3 , args: args}
          sections[cur_section][cur_function][:code].push l
        end
      end
    end

  end
end

puts "Read-in completed in #{sections.count} sections"

puts "-"*60

puts "Reading in gprof file"

flat_prof = {}
in_flat = false
File.open(PROF_FILE, 'r') do |gp|
  gp.each_line do |line|
    if line =~ /Flat profile:/ then
      in_flat = true
    end

    if line =~ /Call graph/ then
      in_flat = false
    end

    if in_flat && line =~ /^\s+([0-9.]+)\s+([0-9.]+)\s+([0-9.]+)\s+(([0-9]+)\s+([0-9.]+)\s+([0-9.]+))?\s(.*)$/ then
      flat_prof[$8.strip] = {time_p: $1.to_f, time_cum: $2.to_f, time_self: $3.to_f, calls: $5.to_i, call_self: $6.to_i, call_total: $7.to_i}
    end
  end
end

puts "Read-in completed for gprof file for #{flat_prof.count} functions"
puts "-"*60

#################################
# Initial Analysis - basic blocks
#################################

if STAGES.include? "bb" then

  puts "Starting Basic Block analysis"

  bbs = []
  cur_block = []

  sections[".text"].each do |func, data|
    puts "analysing func: #{func}@#{data[:addr].to_s(16)}"

    data[:code].each do |line|
      cur_block.push line

      base = line[:instr].split(".")[0]
      if BRANCH_INSNS.include?(base) || BRANCH_IT.include?(base) || BRANCH_SUFFIXES.include?(base[-2,2]) || LDST_INSNS.include?(base) || SIMD_LDST_INSNS.include?(base) then
        #Was a non-basic thing
        func_base = func.split(".")[0]
        prof = (flat_prof.include? func_base) ? flat_prof[func_base] : {time_p: 0, time_cum: 0, time_sef: 0, calls:0 , call_self: 0, call_total: 0}
        b = {func: func, addr: data[:addr], size: cur_block.count, code: cur_block.clone, prof: prof}
        bbs.push b
        cur_block = []
      end
    end
  end

  bbs.sort_by! { |bb| bb[:size] }.reverse!

  puts "#{bbs.count} Basic Blocks completed"
  puts "-"*60

end

#######################################
# Initial Analysis - arithmetic chunks
#######################################


if STAGES.include? "arith" then

  puts "Starting arithmetic analysis"

  bbs.each do |bb|
    puts "analysing bb: #{bb[:func]}@#{bb[:addr].to_s(16)}"

    arith_num = 0
    arith_seq = 0
    max_arith_seq = 0

    bb[:code].each do |line|
      if ARITH_INSNS.include? line[:instr] then
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

end

#################################
# SIMD analysis
#################################

if STAGES.include? "simd" then

  puts "Starting SIMD analysis"

  bbs.each do |bb|
    puts "analysing bb: #{bb[:func]}@#{bb[:addr].to_s(16)}"

    bb[:has_simd] = false
    arith_num = 0
    arith_seq = 0
    max_arith_seq = 0

    bb[:code].each do |line|
      base = line[:instr].split(".")[0]
      if SIMD_ARITH_INSNS.include? base then
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

  bbs_simd = bbs.select { |bb| bb[:has_simd] }
  puts "SIMD analysis conclude - found #{bbs_simd.count} BBs"
  puts "-"*60

end

#######################################
# BBs Gen assignment
#######################################

bbs_gen = bbs.sort_by{|bb| bb[:prof][:time_p] }.reverse.select do |bb|
  ((bb[:arith_seq] > MIN_NUM_ARITH) || (bb[:simd_arith_seq] > MIN_NUM_ARITH)) && (bb[:size] > MIN_SIZE) && (bb[:prof][:time_p] > MIN_RUNTIME_PERCENTAGE)
end.take(NUM_TAKE).reverse

#######################################
# Verilog Generation
#######################################

if STAGES.include? "gen" then

  puts "Verilog Generation started"

  bbs_gen.each do |bb|

    puts "order analysing bb: #{bb[:func]}@#{bb[:addr].to_s(16)}"

    used_regs = {}
    bb[:code].each do |line|
      line[:deps] = []
      line[:deps_lines] = []

      #check for deps
      line[:args].each do |arg|
        if arg[0] == '#' then
          #immediate argument, err...
        else
          #register
          if used_regs.include? arg then
            #dependency
            unless (line[:deps_lines].include? used_regs[arg][:addr]) || (line[:addr] == used_regs[arg][:addr]) then
              line[:deps].push used_regs[arg]
              line[:deps_lines].push used_regs[arg][:addr]
            end
          end
          used_regs[arg] = line
        end
      end
    end

    puts "parallelizing bb: #{bb[:func]}@#{bb[:addr]}: #{bb[:code].count} lines"

    seen_lines = []
    bb[:par_code] = []

    if bb[:code].count < MAX_PARALLEL then
      bb[:code].reverse_each do |line|
        unless seen_lines.include? line[:addr] then
          ret = pars_r(line, seen_lines)
          seen_lines.concat(ret[:seen_lines]).uniq!
          bb[:par_code].push ret[:lines]
        end
      end

      puts "parallelized into #{bb[:par_code].count} pars"
    else
      puts "skipping paralleliziation due to size"
    end

    puts "generating bb: #{bb[:func]}@#{bb[:addr]}"
    #TODO: statement transliteration
    puts "################"
    puts "#{bb[:func]}@#{bb[:addr]}->"
    puts "A #{bb[:arith_num]} #{bb[:arith_seq]} #{bb[:arith_num_p]} #{bb[:arith_seq_p]}"
    puts "S #{bb[:simd_arith_num]} #{bb[:simd_arith_seq]} #{bb[:simd_num_p]} #{bb[:simd_seq_p]}" if bb[:has_simd]
    pp bb[:prof]
    puts "pars: #{bb[:par_code].count}"
    puts "################"

  end

  puts "Verilog Generation concluded"

end
