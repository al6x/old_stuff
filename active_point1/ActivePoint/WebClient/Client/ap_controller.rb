module ActivePoint
	module Engine
		class APController
			UI_NAME = "UI"
			
			def _create_controller
				return NilController.new if object == nil		
				
				controller_class = APController.ui_controller_for object.class
				controller = controller_class.new
				return controller
			end				
			
			class NilController
				def view
					WLabel.new to_l("Object not specified!")			
				end
			end	
			
			#	alias_method :object_has_been_changed_original, :object_has_been_changed
			#	def object_has_been_changed
			#		clear_view
			#		object_has_been_changed_original
			#	end		
			
			class << self
				def ui_controller_for object_klass
					object_klass.class.should! :be, [Class, Module]
					
					object_klass.ancestors.each do |anc|
						next unless anc.is? Entity
						
						short_name = anc.name.split('::').last					
						anc.each_namespace do |ns|
							class_name = "#{ns.name}::#{UI_NAME}::#{short_name}"
							next unless RubyExt::Resource.class_exist? class_name
							
							controller_class = eval class_name, TOPLEVEL_BINDING, __FILE__, __LINE__							
							controller_class.should! :be, Controller
							unless controller_class.instance_methods.include? "view"
								raise NameError, "UI Controller '#{controller_class}' should respond_to :view!" 								
							end
							return controller_class							
						end
					end
					
					raise NameError, "No UI Controller class for '#{object_klass.name}' Entity Object!"
				end
			end
		end
	end	
end