class EditChild < Action	
	attr_accessor :edit_action, :go_to, :skip_if_single, :confirm_delete
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
				selected.sort.reverse_each do |child|
					operation_processor.execute klass, name, :entity => object, :mode => :delete, :child => child
				end
			else
				operation_processor.execute klass, name, :entity => object, :mode => :delete
			end      
		
		finish
	end 
	
	def execute_edit
		ps = klass.operations[name].parameters
		
		if ps[:select] and ps[:custom]
			raise "Not Implemented"
			
		elsif values_call = ps[:select]
			values = values_call.call object
			if values.size == 1 and skip_if_single
				@single_select = values[0]
				edit_child_view
			else
				select_form = Select.new :metadata => self
				select_form[:select].values = values
				controller.view = select_form
			end
		elsif ps[:custom]
			select_form = SelectCustom.new :metadata => self
			controller.view = select_form
		else
			raise "Invalid Parameters for '#{name}' Operation!"
		end
	end
	
	def edit_child_view						
		select = @single_select || view.values[:select]
		
		@child = begin
			child_class = if select.is_a? String
				eval select, binding, __FILE__, __LINE__
			else
				select
			end
			child_class.new
		rescue Exception => e
			log.error "Can't instantiate the '#{select}' Class (#{e.message})"
			raise e
		end
		
		controller.execute edit_action, :object => @child
	end			
	
	def resume
		Transactional.transaction do 			
			operation_processor.execute klass, name, :entity => object, :child => @child, :mode => :update 
		end										
		
		finish        
	end
	
	def choose_next
		case mode
			when :update
			case go_to
				when :child
				controller.object = @child
				when :parent
				controller.execute :on_view
			end
			when :delete
			controller.execute :on_view
		end		
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