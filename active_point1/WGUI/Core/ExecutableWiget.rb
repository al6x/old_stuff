module ExecutableWiget
	
	# TODO Add :message to display when action starts
	
	def disabled?; 
		@disabled = false if @disabled == nil
		@disabled
	end
	attr_writer :disabled
	
	def execute action_name
		disabled?.should! :be_false
		visible?.should! :be_true
		
		action = actions[action_name][1]		
		action.call if action and !disabled? and visible?
	end

	def on action_name, inputs = [], &b
		inputs = inputs.is_a?(Array) ? inputs : [inputs]
		inputs.each do |w| 
			raise_without_self "Inputs should be 'Wiget', but is '#{w.class}'!", WGUI unless w.is_a? Core::Wiget		
		end
				
		actions[action_name] = inputs, b
	end
	
	def inputs_for action_name
		actions[action_name][0]
	end
		
	def js_for action_name
		inputs = inputs_for action_name
		args = if inputs.empty?
			"'#{component_id}', '#{action_name}'"
		else
			%{'#{component_id}', '#{action_name}', ['#{inputs.collect{|input| input.component_id}.join("', '")}']}
		end
		return "wgui.ajax_call(#{args}); return false;"	
	end
	
	protected
	def actions
		@actions ||= Hash.new{|hash, key| raise "There is no such Action: '#{key}'!"}	
	end
end