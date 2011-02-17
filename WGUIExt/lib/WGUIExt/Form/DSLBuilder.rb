class DSLBuilder
	attr_accessor :form, :dsl_builder, :object
	
	[:select].each{|m| undef_method m}
	
	def initialize &dsl
		@dsl = dsl
	end
	
	def build form, object
		@form, @object = form, object
		
		@current_container = form
		@current_container.dsl_builder = self
		instance_eval &@dsl	
	end	
	
	def on
		@form.should_not! :be_nil
		@form.on
	end
	
	def method_missing method, *params, &b		
		dsl_method = :"dsl_#{method}"
		if Form::TYPES.include? method
			add_wiget method, params, &b			
		elsif @current_container.respond_to? dsl_method
			@current_container.send dsl_method, *params, &b
		elsif @current_container.respond_to? method
			@current_container.send method, *params, &b
		else
			super
		end
	end
	
	def new wiget_alias, parameters = nil, &b		
		parameters.should! :be_a, [NilClass, Hash]
		
		klass = Form::TYPES[wiget_alias]		
		wiget = klass.new
		if parameters
			wiget.set! parameters
			attr = parameters[:attr]
			form[attr] = wiget if attr
		end		
		
		if b				
			restore = @current_container
			@current_container = wiget
			@current_container.dsl_builder = self
			instance_eval &b
			@current_container = restore
		end		
		
		return wiget
	end
	
	def localization_self
		@form
	end
	
	protected
	def add_wiget wiget_alias, params, &b						
		if params.size > 0 and params.last.is_a? Hash
			arguments, parameters = params[0..-2], params.last
		else
			arguments, parameters = params, nil
		end
		
		wiget = new wiget_alias, parameters, &b		
		@current_container.dsl_add_wiget wiget, *arguments
		return wiget
	end
end