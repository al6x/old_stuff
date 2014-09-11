#WGUI::Core::ExecutableWiget
#module WGUI::Core::ExecutableWiget
#	alias_method :old_execute, :execute
#	def execute *params, &b
#		begin
#			old_execute *params, &b
#		rescue Exception => e
#			Scope[WebClient::Tools::Messages].error e.message
#			raise e
#		end
#	end
#end