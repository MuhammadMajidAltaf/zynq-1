require 'analysis/phase'

module Phases
  class Read < Phase

    def self.run s
      sections = {}

      puts "Reading in objdump"

      cur_section = nil
      cur_function = nil
      File.open(s[:options][:disassembly_file], 'r') do |obj|
        obj.each_line do |line|

          if line =~ /Disassembly of section (.*):$/ then
            cur_section = $1.strip
            cur_function = nil
            puts "sec #{cur_section}"
            sections[cur_section] = {} unless sections.key? cur_section
          end

          unless cur_section.nil? then
            if line =~ /^([0-9a-f]+) <(.*)>:/ then
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

                addr = $1.to_i(16)
                raw = $2
                instr = $3

                unless $4.nil? then
                  $4.match(/\d+\s\<([\w]+)(\+([\dx]+))?\>/)
                  offset = $3.nil? ? nil : $3.to_i(16)
                  branch = { base: $1, offset: offset }
                end
                l = { addr: addr, raw: raw, instr: instr, args: args, branch: branch}
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
      File.open(s[:options][:gprof_file], 'r') do |gp|
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

      new = {sections: sections, flat_prof: flat_prof}
      return s.merge new
    end
  end
end
