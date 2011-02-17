module Form
	include OpenConstructor, WGUI::WigetContainer, Containers::Container
	attr_accessor :root, :form_instance_dsl
	
	TYPES = self["types.rb"] 		
	
	children :@root				
	
	def editors
		@editors
	end
	
	def dsl_add_wiget root
		root.should_not! :be_nil
		@root = root
	end
	
	def object
		@object.should_not! :be_nil
	end
	def object= object
		@object = object
		refresh
	end
	
	def new klass, parameters	= {}			
		w = View.create_wiget klass, parameters
		if attr = parameters[:attr]
			self[attr] = w
		end
		return w
	end
	
	def [] attr
		editors[attr]
	end
	
	def aspects
		@aspects ||= {}
	end
	
	def []= attr, editor
		editor.should! :be_a, Editors::Editor
		@editors[attr] = editor
	end
	
	def values
		values = {}
		editors.values.every.respond_to :write, values
		return values
	end
	
	def values= values
		editors.values.every.respond_to :read, values
	end
	
	def read
		object.should_not! :be_nil
		self.values = object
	end
	
	def write
		object.should_not! :be_nil
		object.set values
	end
	
	def build
		@editors = {}
		unless form_instance_dsl
			@inherited = false
			inherit!
		else
			builder = DSLBuilder.new &form_instance_dsl
			builder.build self, @object
		end
		read if @object		
	end
	
	# on[:ok] = lambda{}
	def on
		@on ||= Hash.new{where?; should! :be_never_called}
	end
	
	class << self
		def class_for_alias alias_or_class
			klass = TYPES[alias_or_class] || alias_or_class
			klass.class.should! :be, Class
			return klass
		end
		
		def create_wiget klass, parameters
			klass = class_for_alias klass
			w = klass.new
			w.set_with_check parameters
			return w
		end
		
		def common_form wiget_alias = :tab, parameters = {}, &b
			object = parameters.delete :object
			form = CommonForm.new.set :object => object
			form.form_instance_dsl = lambda{send wiget_alias, parameters, &b}
			return form
		end
		
		def common_dialog &b
			form = CommonForm.new
			form.form_instance_dsl = lambda do
				object.should_not! :be_nil
				box :title => object[:title], :css => "padding" do
					attributes &b
					line :wide => false do
						button :text => `Ok`, :action => [form, on[:ok]]
						button :text => `Cancel`, :action => on[:cancel]
					end
				end
			end			
			return form
		end
	end
	
	def inherit!
		@inherited.should_not! :be_true
		forms = self.class.ancestors.select{|a| a.is? Form}
		forms.reverse.each do |klass|			
			if dsl = klass.form_class_dsl
				builder = DSLBuilder.new &dsl
				builder.build self, @object 
			end
		end
		@inherited = true
	end
	protected :inherit!
	
	#	def subflow *args
	#		@root_wrapper.subflow *args
	#	end
	#	
	#	def answer *args
	#		@root_wrapper.answer *args
	#	end
	#	
	#	def cancel *args
	#		@root_wrapper.cancel *args
	#	end
	
	module ClassMethods
		def build wiget_alias = :tab, parameters = {}, &b
			wiget_alias.should! :be_a, Symbol			
			self.form_class_dsl = lambda{send wiget_alias, parameters, &b}			
		end
		
		def form_class_dsl; @form_builder end
		
		def form_class_dsl= b; @form_builder = b end							
	end
	extend ClassMethods
end

#class View < WComponent  
#	inherit ViewAspect
#	
#	   
#	
#	def initialize properties = nil		
#		super()			
#		set properties if properties
#		inherit!
#	end		    		
#end