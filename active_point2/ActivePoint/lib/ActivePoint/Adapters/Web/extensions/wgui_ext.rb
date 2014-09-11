module WGUIExt	
	module Utils
		class Extension
			class << self
				def get_data_storage
					R
				end
				
				def get_name object
					object ? object.name : ""
				end
				
				def get_object
					Scope[ActivePoint::Adapters::Web::AppController].object
				end
				
				def get_parent object
					object ? object.parent : nil
				end
				
				def each_child object, &b
					object.each(:child, &b)
				end
				
				def get_portlet
					Scope[ActivePoint::Adapters::Web::App]
				end
				
				def view_state_get component_id
					Scope[ActivePoint::Adapters::Web::App::WigetsState][component_id]
				end
				
				def view_state_set component_id, state
					Scope[ActivePoint::Adapters::Web::App::WigetsState][component_id] = state
				end
				
				def get_path object
					object.should! :be_a, ::ObjectModel::Entity
					object.path
				end
				
				def get_object_by_path path
					R[path]
				end
				
				def get_id object
					object.entity_id
				end
			end
		end		
	end		
	
	Controls::Control
	module Controls::Control
		def action= params
			inputs, action, @arguments = if params.is_a? Array				
				params.size.should! :>=, 1
				if params[0].is_a?(Symbol) or params[0].is_a?(Proc)
					[[], params[0], (params[1..-1] || [])]
				else
					params[0].should! :be_a, WGUI::Wiget
					params.size.should! :>=, 2
					[params[0], params[1], (params[2..-1] || [])]
				end				
			else 			
				[[], params, []]
			end		
			
			action.should! :be_a, [Symbol, Proc]
			if action.is_a? Symbol
				@action_method = action
				action = lambda{C.controller.send @action_method, *@arguments}
			end
			
			self.action inputs, &action
		end
		
		def visible?
			return false unless super
			
			if @action_method
				if @arguments
					C.class.can_execute_method? C.user, C.object, @action_method, *@arguments
				else
					C.class.can_execute_method? C.user, C.object, @action_method
				end
			else
				true
			end
		end
	end
	
	Editors::ObjectLink
	class Editors::ObjectLink
		def visible?
			return false unless super
			
			if @object
				controller_class = C.controller_for @object
				controller_class.can_execute_method? C.user, @object, :show
			else
				true
			end
		end
	end
	
	Form
	module Form
		#		def aspects
		#			self[:aspects] ||= new :box
		#		end
		
		alias_method :original_read, :read
		def read
			R.transaction{original_read}
		end
	end
end