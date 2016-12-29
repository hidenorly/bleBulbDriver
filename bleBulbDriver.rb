#!/usr/bin/ruby

# Copyright 2016 hidenorly
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'optparse'
require 'timeout'

BEGIN { $BASETIME = Time.now.to_i }

SUPPORTED_DEVICES=[
	"SATECHILED"
]

def isSupportedDevice(deviceName)
	SUPPORTED_DEVICES.each do | aSupported |
		return aSupported if deviceName.start_with?( aSupported )
	end
	return nil
end

def getSupportedBLEDevices
	result = []
	exec_cmd = "stdbuf -oL -eL hcitool lescan"

	pio = nil
	begin
		Timeout.timeout(3) do
			pio = IO.popen(exec_cmd, "r").each do |line|
				line.to_s.strip!
				if !line.include?("(unknown)") then
					pos = line.index(" ")
					if pos!=nil then
						deviceName = line.slice(pos+1, line.length)
						deviceType=isSupportedDevice(deviceName)
						if deviceType then
							macAddr = line.slice(0,pos)
							result << {:macAddr=>macAddr, :deviceName=>deviceName, :deviceType=>deviceType}
						end
					end
				end
			end
		end
	rescue Timeout::Error => ex
		if pio then
			if pio.pid then
				puts pio.pid
				Process.kill(9, pio.pid)
			end
			pio.close
		end
	end

	return result
end

def turnDeviceOn(device, turnOn)
	exec_cmd = "gatttool --device=#{device[:macAddr]} "

	case device[:deviceType]
	when "SATECHILED"
		exec_cmd += " --char-write-req --handle=0x002b --value="
		if turnOn then
			exec_cmd += "0f0d0300ffffffc800c800c8000059ffff"
		else
			exec_cmd += "0f0d0300ffffff0000c800c8000091ffff"
		end
	end

	if exec_cmd.include?("--value") then
		IO.popen(exec_cmd, "r")
	end
end


options = {
	:macAddr => nil,
	:deviceType => "SATECHILED",
	:color => "ffffff"
}

opt_parser = OptionParser.new do |opts|
	opts.banner = "Usage: listDevices|on|off|allOn|allOff"
	opts.on_head("bleBulbDriver Copyright 2016 hidenorly")
	opts.version = "1.0.0"

	opts.on("-b", "--target=", "Set target device's mac address") do |macAddr|
		options[:macAddr] = macAddr
	end

	opts.on("-t", "--type=", "Set device type (default:#{options[:deviceType]})") do |deviceType|
		options[:deviceType] = deviceType
	end

	opts.on("-c", "--color=", "set color (default:#{options[:color]})") do |color|
		options[:color] = color
	end
	if ARGV.length==0 then
		puts opts.to_s
		exit(-1)
	end
end.parse!

if ARGV.length then
	cmd = ARGV[0].to_s.downcase
	case cmd
	when "listdevices"
		devices = getSupportedBLEDevices()
		devices.each do | aDevice |
			puts "#{aDevice[:macAddr]} #{aDevice[:deviceName]}"
		end
	when "on", "off"
		turnDeviceOn({:macAddr=>options[:macAddr], :deviceType=>options[:deviceType]}, cmd=="on" ? true : false )
	when "allon","alloff"
		devices = getSupportedBLEDevices()
		devices.each do | aDevice |
			turnDeviceOn( aDevice, cmd=="allon" ? true : false )
		end
	end
end
