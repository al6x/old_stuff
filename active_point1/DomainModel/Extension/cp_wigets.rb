# metadata == action

WebClient::Wigets::Containers::Attributes.label_resolver = lambda do |metadata, label|
	begin
		metadata.klass.dmeta.attributes[label].title
	rescue Exception => e
		warn e
 		"Can't evaluate title!"
	end
end

WebClient::Wigets::Controls::Button.label_resolver = lambda do |metadata, action_name|
	metadata.klass.vmeta.actions[action_name].parameters[:title]
end

WebClient::Wigets::Controls::Button.action_resolver = lambda do |metadata, action_name|
	lambda{metadata.controller.execute action_name}
end