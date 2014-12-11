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

#takes hash input, returns some stats as hash
def getRail(rail)
  rail_path = File.join(SYS_PATH, "hwmon#{rail[:ctrl]-CTRL_BASE_ID}")
  stats = {}
  stats[:V] = File.read(File.join(rail_path, "in#{rail[:rail]+1}_input")).to_i
  stats[:I] = File.read(File.join(rail_path, "curr#{rail[:rail]+1}_input")).to_i
  stats[:P] = File.read(File.join(rail_path, "power#{rail[:rail]+1}_input")).to_i
  stats[:T] = File.read(File.join(rail_path, "temp#{rail[:rail]+1}_input")).to_i
  stats[:Vdiff] = (stats[:V] - rail[:Vtarget]).abs

  stats
end

def getRails(rails = {})
  rails = ['VCCINT','VCCPINT','VCCAUX','VCCPAUX','VCCADJ','VCC1V5','VCCMIO_PS','VCCBRAM','VCC3V3','VCC2V5'] if rails.empty?
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

while true do
  stats = {}

  begin
    stats = getRails
  rescue
    stats = {}
    next
  end

  puts "#{(Time.now.to_f*1000*1000).to_i}"
  puts getRails
  puts getMemory
  puts "----------------------------------"

  sleep 0.5
end
