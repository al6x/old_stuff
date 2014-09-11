require "#{File.dirname __FILE__}/definitions"

UserInputService.instance.wf_engine = $engine

li = OpenWFE::LaunchItem.new(AsynchronousProcess)
fei = $engine.launch(li)
#engine.wait_for(fei)
sleep 1