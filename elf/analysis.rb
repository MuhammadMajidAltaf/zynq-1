#!/usr/bin/env ruby
require 'rubygems'
require 'pp'

BRANCH_INSNS = ['bl', 'blx', 'bx', 'cbnz', 'cbz', 'b', 'tbb', 'tbh']
BRANCH_SUFFIXES = ['eq', 'ne', 'cs', 'cc', 'mi', 'pl', 'vs', 'vc', 'hi', 'ls', 'ge', 'lt', 'gt', 'le']
BRANCH_IT = ['it', 'itt', 'ite', 'itt', 'itet' ,'itte', 'itee', 'itttt', 'itett', 'ittet', 'iteet', 'ittte' ,'itete' ,'ittee', 'iteee']

ARITH_INSNS = ['adc', 'add', 'adds', 'addw', 'and', 'bic', 'eor', 'mov', 'mvn', 'orn', 'orr', 'rsb', 'sbc', 'sub', 'subs', 'subw', 'asr', 'asl', 'lsl', 'lsr', 'ror', 'rrx', 'mla', 'mls' , 'mul', 'smlal', 'smull', 'umlal', 'umull', 'ssat', 'usat', 'sxtb', 'sxth', 'uxtb', 'uxth', 'sdiv', 'udiv', 'bfc', 'bfi', 'clz', 'movt', 'rbit', 'rev', 'rev16', 'revsh', 'sbfx', 'ubfx']

if ARGV.length < 1 then
  puts "Not enough arguments"
  puts "[objdump-file]"
  exit
end

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
          l = { addr: $1, raw: $2, instr: $3 , args: $5}
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

bbs_asp = bbs.sort_by { |bb| bb[:arith_seq_p] }.reverse.select { |bb| bb[:size] > 5 && bb[:arith_seq_p] > 50 }.sort_by{ |bb| bb[:size] }.reverse.take(20)

pp bbs_asp

puts "Arithmetic analysis concluded"
