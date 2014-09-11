DomainModel::Actions::TYPES = DomainModel::Actions["types.rb"]

class DomainModel::VMeta
	class Actions < Hash	
		def copy
			c = Actions.new
			each{|n, m| c[n] = m.copy}
			return c
		end
		
		def inherit parent
			result = self.merge(parent){|key, cmeta, pmeta|					
				action_class = cmeta.class
				custom_inheritor = action_class.respond_to :inheritor					
				if custom_inheritor
					custom_inheritor.call pmeta, cmeta
				else
					cmeta
				end
			}				
			result
		end
	end
	
	class Action
		include OpenConstructor
		
		attr_accessor :name, :title, :class, :parameters
		
		def copy; clone end
	end
	
	class ActionsDefinition		
		class << self
			def initial_value; Actions.new end
			
			def copy actions; actions.copy end
			
			def inherit pvalue, cvalue;  						
				cvalue.inherit pvalue
			end				
		end
	end
	
	definition[:actions] = ActionsDefinition
	
	attr_accessor :actions
	
	class Helper
		def action name, klass, parameters = nil
			klass = DomainModel::Actions::TYPES[klass] || klass
			values = {:name => name, :class => klass}
			a = Action.new.set_with_check values
			a.parameters = parameters if parameters
			vmeta.actions[name] = a
		end
	end
end