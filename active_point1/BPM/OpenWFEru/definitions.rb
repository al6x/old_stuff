require 'openwfe/engine'
require 'openwfe/engine/fs_engine'
require 'singleton'
require "#{File.dirname __FILE__}/async_participant"

class AsynchronousProcess < OpenWFE::ProcessDefinition
	sequence do
		participant "Collect User Input"
		participant "Display User Input" 
	end  
end

class UserInputService < AsyncService
	include Singleton
	
	def receive_msg sfei, participant_name, answer	
		# Prepare Answer here before returning it to AsyncBlock
		super sfei, participant_name, answer
	end
	
	def send_msg sfey, participant_name, question		
		# Prepare Question here before sending it to some remote Servise
		p "The Question is: #{question}"
		File.open("wfid", "w"){|f| f.write Marshal.dump([sfey, participant_name])}
	end
end

class CollectUserInput < AsyncBlock
	def send_msg workitem
		"How are you?"
	end
	
	def receive_msg workitem, result
		workitem.user_input = result
	end
	
	def service
		UserInputService.instance
	end
end

$engine = OpenWFE::FsPersistedEngine.new(:definition_in_launchitem_allowed => true)
$engine.register_participant "Collect User Input", CollectUserInput.new
$engine.register_participant "Display User Input" do |workitem|
	p "UserInput is: #{workitem.user_input}"
end