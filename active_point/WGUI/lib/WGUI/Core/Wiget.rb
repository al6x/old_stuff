class Wiget
	include OpenConstructor
	
	def refresh; 
		@refresh = true 
	end	
	def refresh= value
		@refresh = value
	end		
	def refreshed?;
		@refresh = true if @refresh == nil
		@refresh
	end 
	
	# TODO add check for visible before perform any value update or execute action
	def visible?; 
		@visible = true if @visible == nil
		@visible
	end
	
	def visible= value
		@visible = value
		refresh
	end
	
	attr_reader :css
	def css= css
		if css
			@css ||= ""
			@css += " #{css}"
		else
			@css = nil
		end		
		refresh
	end
	
	def to_html; 		
		html = visible? ? Utils::TemplateHelper.render_template(self.class, :binding => binding) : ""
		return Utils::TemplateHelper.render_template(Wiget, :binding => binding)
	end
	
	def visit visitor
		visitor.accept(self)
		return visitor
	end
	
	def component_id=(id); 
		id = id.to_s
		raise "component_id cannot be empty!" if id.empty?
		@component_id = id
	end
	
	def component_id; 
		@component_id ||= Scope[Utils::IDGenerator].generate(self.class.name)
	end
	
	def to_s; component_id end	
		
	def inspect; to_s end
end