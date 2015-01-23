#!/usr/bin/env ruby

SYS_PATH = '/sys/class/hwmon/'
MEMINFO_PATH = '/proc/meminfo'
CTRL_BASE_ID = 52
RAILS = {'VCCINT'  => {ctrl: 52, rail: 1, Vtarget: 1000},
         'VCCPINT' => {ctrl: 52, rail: 2, Vtarget: 1000},
         'VCCAUX'  => {ctrl: 52, rail: 3, Vtarget: 1800},
         'VCCPAUX' => {ctrl: 52, rail: 4, Vtarget: 1800},
         'VCCADJ'  => {ctrl: 53, rail: 1, Vtarget: 2500},
         'VCC1V5'  => {ctrl: 53, rail: 2, Vtarget: 1500},
         'VCCMIO_PS' => {ctrl: 53, rail: 3, Vtarget: 1800},
         'VCCBRAM' => {ctrl: 53, rail: 4, Vtarget: 1000},
         'VCC3V3'  => {ctrl: 54, rail: 1, Vtarget: 3300},
         'VCC2V5'  => {ctrl: 54, rail: 2, Vtarget: 2500}}
RAIL_STATS = {:V => 'in',
              :I => 'curr',
              :P => 'power',
              :T => 'temp'}

#takes hash input, returns some stats as hash
def getRail(rail)
  rail_path = File.join(SYS_PATH, "hwmon#{rail[:ctrl]-CTRL_BASE_ID}")
  stats = {}
  RAIL_STATS.each do |name, str|
    stats[name] = File.read(File.join(rail_path, "#{str}#{rail[:rail]+1}_input")).to_i
  end
  stats
end

def getRails(rails = {})
  stats = {}
  rails.each do |name|
    stats[name] = getRail(RAILS[name])
  end

  stats
end

def getMemory()
  stats = {}
  File.read(MEMINFO_PATH).each_line do |line|
    parts = line.gsub(/\s+/," ").split(" ")
    stats[parts[0]] = parts[1]
  end

  stats
end

######################################################
sleep_time   = ARGV.count > 0 ? ARGV[0].to_i : 0.5
reps         = ARGV.count > 1 ? ARGV[1].to_i : 100
stats_file = ARGV.count > 2 ? ARGV[2] : "stats-#{Time.now.to_i}"
rails        = ARGV.count > 3 ? ARGV[3] : ['VCCINT','VCCPINT','VCCAUX','VCCPAUX','VCCADJ','VCC1V5','VCCMIO_PS','VCCBRAM','VCC3V3','VCC2V5']

File.open(stats_file, "w") do |fd|
  fd.print "t,"
  rails.each do |rail|
    RAIL_STATS.each do |name, str|
      fd.print "#{rail}.#{name},"
    end
  end
  getMemory.keys.each do |key|
    fd.print "M.#{key},"
  end
  fd.puts ""

  while (reps > 0 || reps == -1) do
    cur_time = (Time.now.to_f*1000*1000).to_i
    begin
      r = getRails rails
      m = getMemory
    rescue
      puts "Error getting data this loop: #{$!}"
      next
    end

    buf = "#{cur_time},"
    rails.each do |rail|
      RAIL_STATS.each do |name, str|
        buf << "#{r[rail][name]},"
      end
    end
    m.each_value do |val|
      buf << "#{val},"
    end
    fd.puts buf

    sleep sleep_time
    reps = reps - 1
  end
end
