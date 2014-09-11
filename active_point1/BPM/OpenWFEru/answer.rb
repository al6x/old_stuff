require "#{File.dirname __FILE__}/definitions"

UserInputService.instance.wf_engine = $engine

sfei, pname = File.open("wfid"){|f| Marshal.load(f.read)}
puts "Enter Answer"
answer = gets
UserInputService.instance.receive_msg sfei, pname, answer
#$engine.wait_for(fei)

sleep 1