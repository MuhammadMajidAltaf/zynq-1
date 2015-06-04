#!/usr/bin/env ruby
require 'analysis'
require 'optparse'
require 'pp'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: analyze.rb [options]"

  opts.on("-d", "--dissassembly-file FILE", "objdump dissassembly file of target binary") do |f|
    options[:disassembly_file] = f
  end
  opts.on("-n", "--num-taken N", Integer, "Maximum number of basic blocks to consider") do |n|
    options[:num_taken] = n
  end
  opts.on("-s", "--stages STAGES", "Stages to run, colon seperated") do |s|
    options[:stages] = s.split(":")
  end
  opts.on("-g", "--gprof-file FILE", "GNUProf Profiling file for the target binary") do |f|
    options[:gprof_file] = f
  end
  opts.on("-p", "--num-parallel N", Integer, "Maximum number of parallel sections to consider") do |n|
    options[:num_parallel] = n
  end
  opts.on("-r", "--min-runtime-percentage N", Integer, "Minimum percentage of runtime threshold for considering") do |n|
    options[:min_runtime_percentage] = n
  end
  opts.on("-a", "--min-num-arith N", Integer, "Mininum number of sequential arithmetic instructions for fusing") do |n|
    options[:min_num_arith] = n
  end
  opts.on("-l", "--min-length N", Integer, "Minimum length of basic block to consider") do |n|
    options[:min_length] = n
  end
  opts.on("-L", "--load-dump-file FILE", "Dump file to load from if appropriate") do |f|
    options[:load_dump_file] = f
  end
  opts.on("-S", "--save-dump-file FILE", "Dump file to save to if appropriate") do |f|
    options[:save_dump_file] = f
  end
end.parse!

#Check required arguments
if options[:disassembly_file].nil? ||
  options[:stages].nil? ||
  (!options[:stages].nil? && options[:stages].length == 0) ||
  options[:gprof_file].nil?
  raise OptionParser::MissingArgument, "Need disassembly file, stages and gprof file"
end

#Add default values for missing
options[:num_taken] ||= Defaults::NUM_TAKEN
options[:num_parallel] ||= Defaults::NUM_PARALLEL
options[:min_runtime_percentage] ||= Defaults::MIN_RUNTIME_PERCENTAGE
options[:min_num_arith] ||= Defaults::MIN_NUM_ARITH
options[:min_length] ||= Defaults::MIN_LENGTH

#Check valid stage names
valid_stages = Phase.descendants.collect do |s|
  s.to_s[8..s.to_s.length]
end
options[:stages].each do |stage|
  unless valid_stages.include? stage
    raise OptionParser::MissingArgument, "Missing stage #{stage}. Valid stages are: #{valid_stages.join(",")}"
  end
end

####################################################
# Run the Stages in the order specified
####################################################
state = {:options => options}
options[:stages].each do |stage|
  p stage
  p state.keys
  state = Module.const_get("Phases::#{stage}").run state
end
