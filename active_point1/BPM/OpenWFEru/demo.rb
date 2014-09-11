require 'openwfe/engine'
require "#{File.dirname __FILE__}/async_participant"

engine = OpenWFE::FsPersistedEngine.new()#:definition_in_launchitem_allowed => true)
Thread.abort_on_exception=true
class AsynchronousProcess < OpenWFE::ProcessDefinition
	sequence do
		participant "Collect User Input"
		participant "Display User Input" 
	end  
end

class CollectUserInput < AsyncBlock
	def send_msg workitem
		"How are you?"
	end
	
	def receive_msg workitem, result
		workitem.user_input = result
	end
#	
	def service
		$user_input_service
	end
end

engine.register_participant "Collect User Input", CollectUserInput.new
engine.register_participant "Display User Input" do |workitem|
	p "UserInput is: #{workitem.user_input}"
end

class UserInputService < AsyncService
	def receive_msg sfei, participant_name, answer	
		# Do business here
		super sfei, participant_name, answer
	end
	
	def send_msg sfey, participant_name, question		
		# Do business here
		p "The Question is: #{question}"
		File.open("wfid"){|f| f.write Marshal.dump([sfey, participant_name])}
	end
end

$user_input_service = UserInputService.new
$user_input_service.wf_engine = engine

Thread.new do 
	answer = gets
	$user_input_service.receive_msg $sfei, $pname, answer
end

li = OpenWFE::LaunchItem.new(AsynchronousProcess)
fei = engine.launch(li)
engine.wait_for(fei)

sleep 1000