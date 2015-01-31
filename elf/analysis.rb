#!/usr/bin/env ruby
require 'rubygems'
require 'pp'

BRANCH_INSNS = ['bl', 'blx', 'bx', 'cbnz', 'cbz', 'b', 'tbb', 'tbh']
BRANCH_SUFFIXES = ['eq', 'ne', 'cs', 'cc', 'mi', 'pl', 'vs', 'vc', 'hi', 'ls', 'ge', 'lt', 'gt', 'le']
BRANCH_IT = ['it', 'itt', 'ite', 'itt', 'itet' ,'itte', 'itee', 'itttt', 'itett', 'ittet', 'iteet', 'ittte' ,'itete' ,'ittee', 'iteee']

ARITH_INSNS = ['adc', 'add', 'adds', 'addw', 'and', 'bic', 'eor', 'mov', 'mvn', 'orn', 'orr', 'rsb', 'sbc', 'sub', 'subs', 'subw', 'asr', 'asl', 'lsl', 'lsr', 'ror', 'rrx', 'mla', 'mls' , 'mul', 'smlal', 'smull', 'umlal', 'umull', 'ssat', 'usat', 'sxtb', 'sxth', 'uxtb', 'uxth', 'sdiv', 'udiv', 'bfc', 'bfi', 'clz', 'movt', 'rbit', 'rev', 'rev16', 'revsh', 'sbfx', 'ubfx']

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

if ARGV.length < 2 then
  puts "Not enough arguments"
  puts "[objdump-file] [num-take]"
  exit
end

NUM_TAKE = ARGV[1].to_i

#Parse in obj-dump file and extract sections

sections = {}
cur_section = nil
cur_function = nil

#################################
# Read in
#################################

puts "Reading in objdump"

filename = ARGV[0]
File.open(filename, 'r') do |obj|
  obj.each_line do |line|

    if line =~ /Disassembly of section (.*):$/ then
      cur_section = $1.strip
      cur_function = nil
      puts "sec #{cur_section}"
      sections[cur_section] = {} unless sections.key? cur_section
    end

    unless cur_section.nil? then
      if line =~ /(\d+) <(.*)>:/ then
        #Section/Function header
        #puts "func:"
        #puts $1
        #puts $2
        cur_function = $2
        sections[cur_section][cur_function] = {addr: $1, code: []} unless sections[cur_section].key? cur_function
      end

      unless cur_function.nil? then
        if line =~ /([0-9a-f]+):\t([0-9a-f ]+)\s\t([a-z.]+)(\t(.*))?$/ then
          #Line
          #puts "line:"
          #puts $1
          #puts $2
          #puts $3
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

#################################
# Initial Analysis - basic blocks
#################################

puts "Starting Basic Block analysis"

bbs = []
cur_block = []

sections[".text"].each do |func, data|
  puts "analysing func: #{func}@#{data[:addr]}"

  data[:code].each do |line|
    cur_block.push line

    base = line[:instr].split(".")[0]
    if BRANCH_INSNS.include?(base) || BRANCH_IT.include?(base) || BRANCH_SUFFIXES.include?(base[-2,2]) then
      #Was a non-basic thing
      b = {func: func, addr: data[:addr], size: cur_block.count, code: cur_block.clone}
      bbs.push b
      cur_block = []
    end
  end
end

bbs.sort_by! { |bb| bb[:size] }.reverse!

puts "#{bbs.count} Basic Blocks completed"

#######################################
# Initial Analysis - arithmetic chunks
#######################################

puts "Starting arithmetic analysis"

bbs.each do |bb|
  puts "analysing func: #{bb[:func]}@#{bb[:addr]}"

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

bbs_asp = bbs.sort_by { |bb| bb[:arith_seq_p] }.reverse.select { |bb| bb[:size] > 5 && bb[:arith_seq_p] > 50 }.sort_by{ |bb| bb[:size] }.reverse.take(NUM_TAKE)

pp bbs_asp

puts "Arithmetic analysis concluded"

#######################################
# Initial Analysis - arithmetic chunks
#######################################

puts "Verilog Generation started"

bbs_asp.each do |bb|

  puts "order analysing func: #{bb[:func]}@#{bb[:addr]}"

  used_regs = {}
  bb[:code].map! do |line|
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

    line
  end

  puts "parallelizing func: #{bb[:func]}@#{bb[:addr]}"

  seen_lines = []
  bb[:par_code] = []
  bb[:code].reverse_each do |line|
    unless seen_lines.include? line[:addr] then
      ret = pars_r(line, seen_lines)
      seen_lines.concat(ret[:seen_lines]).uniq!
      bb[:par_code].push ret[:lines]
    end
  end

  puts "parallelized into #{bb[:par_code].count} pars"

  puts "generating func: #{bb[:func]}@#{bb[:addr]}"
  #TODO: statement transliteration
  puts "################"
  pp bb
  puts "################"

end

puts "Verilog Generation concluded"
