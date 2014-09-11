WebClient::Wigets::View
class WebClient::Wigets::View
	def action name, parameters = {}
		action_class = metadata.klass.vmeta.actions[name].class
		control = begin
			action_class.build_control name, metadata, parameters
		rescue Exception => e
			warn e
			WLabel.new "Can't evaluate control!"
		end
		#		control.respond_to :"metadata=", metadata
		return control
	end
	
	def aparameters attribute_name
		metadata.klass.dmeta.attributes[attribute_name].parameters
	end
end