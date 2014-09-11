class Wrapper < WComponent
	include Container
	
	attr_accessor :component, :accessor
	
	children :content
	
	def content; 
		if @component
			if @accessor 
				Scope[component].send @accessor
			else
				Scope[component]
			end
		else
			nil
		end 
	end
	
	def refreshed?
		if wiget = content
			return wiget.refreshed? if wiget
		end
		return super		
	end
	
#	protected
#	def get_component
#		
#	end
end

#class Wrapper < WGUI::Core::WContinuation
#	include Container
#	
#	attr_accessor :component
#	
#	def original
#		Scope[component]
#	end
#	
#	def refreshed?;
#		if component
#			Scope[component].refreshed?
#		else
#			super
#		end
#	end 
#end