class EditReference < Action	
	attr_accessor :confirm_delete
	attr_accessor :mode, :selected
	
	def execute
		case mode
			when :update then execute_edit
			when :delete then execute_delete  		
		end    	
	end
	
	def execute_delete
		if confirm_delete
			form = Common::OkCancel.new :metadata => self
			form.text = "Delete?"
			form.on_ok{perform_delete}
			form.on_cancel{cancel}
			controller.view = form  	  	  	            
		else
			perform_delete
		end
	end
	
	def perform_delete  
		if selected				
			selected.sort.reverse_each do |ref|
				operation_processor.execute klass, name, :entity => object, :mode => :delete, :reference => ref
			end
		else
			operation_processor.execute klass, name, :entity => object, :mode => :delete
		end      
		
		finish
	end 
	
	def execute_edit		
		ps = klass.operations[name].parameters
		
		values_call = ps[:select]
		values = values_call.call object
		
		#		if values.size == 1
		#			@single_select = values[0]
		#			perform_edit
		#		else
		select_form = Select.new :metadata => self
		select_form[:select].values = values
		controller.view = select_form
		#		end		
	end	
	
	def perform_edit
		select = @single_select || view.values[:select]
		Transactional.transaction do 			
			operation_processor.execute klass, name, :entity => object, :reference => select, :mode => :update 
		end										
		
		finish        
	end
	
	def choose_next		
		controller.execute :on_view
	end
	
	class << self
		# :inputs, :selected
		def build_control action_name, current_action, parameters = {}		
			control = WebClient::Wigets::Containers::Flow.new.set :floating => true, :padding => true
			
			titles = current_action.klass.vmeta.actions[action_name].parameters[:titles]
			tedit, tdelete = titles ? [titles[0], titles[1]] : ["Edit", "Delete"]
			
			edit = WButton.new tedit do
				Scope[Engine::Controller].execute action_name, :mode => :update
			end
			control.add edit
			
			attribute_name = current_action.klass.dmeta.operations[action_name].parameters[:attribute]
			value = current_action.object.send attribute_name
			
			empty = case current_action.klass.container attribute_name
				when :single
				value == nil
				when :array
				value.empty?
			end
			
			unless empty
				delete = WButton.new tdelete do
					rp = {:mode => :delete}
					selected = parameters[:selected]
					rp[:selected] = selected.call if selected
					Scope[Engine::Controller].execute action_name, rp
				end
				delete.inputs = parameters[:inputs] if parameters[:inputs]												
				control.add delete
			end
			return control
		end
	end
end