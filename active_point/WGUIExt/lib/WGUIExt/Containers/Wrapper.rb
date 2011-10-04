class Wrapper < WContinuation	
	attr_accessor :component, :accessor
	
	def original				
		if @component
			cmp = Scope[component]
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
		c = content
		super or (c and c.refreshed?)
	end
	
	def build
		# Needed! Else build will be called twice on component!
	end
	
	#	children :wiget
	#	
	#	def wiget
	#		if @component
	#			if @accessor 
	#				Scope[component].send @accessor
	#			else
	#				Scope[component]
	#			end
	#		else
	#			nil
	#		end 
	#	end
	#	
	#	def refreshed?
	#		wiget ? wiget.refreshed? : super
	#	end 
end

#class Wrapper < WComponent
#	include Container
#	
#	attr_accessor :component, :accessor
#	
#	children :content
#	
#	def content; 
#		if @component
#			if @accessor 
#				v = Scope[component].send @accessor
#				p v
#				v
#			else
#				Scope[component]
#			end
#		else
#			nil
#		end 
#	end
#	
#	def refreshed?
#		if wiget = content
#			return wiget.refreshed? if wiget
#		end
#		return super		
#	end
#end

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