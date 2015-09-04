#!/usr/bin/ruby
#require 'csv'

if ARGV.length < 1
  puts "Need file to act on"
end

initial_time = 0
new_lines = []

File.foreach(ARGV[0]).with_index do |line, i|
  new_lines.push line if i == 0

  splits = line.split(",")

  if i == 1 then
    initial_time = splits[0].to_i
  else
    new_time = (splits[0].to_i - initial_time).to_f/(1000*1000)
    new_lines.push "#{new_time},#{splits.drop(1).join(",")}"
  end
end

File.open(ARGV[0], "w") do |f|
  new_lines.each do |l|
    f.puts l
  end
end
