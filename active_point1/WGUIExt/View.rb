module View
	include OpenConstructor, WGUI::WigetContainer
	
	TYPES = self["types.rb"] 
	
	children :@root_wrapper
	
	attr_accessor :root, :object
	
	def wigets
		@wigets
	end
	
	def root= root
		@root = root
		@root_wrapper = WContinuation.new root
	end
	
	def new klass, parameters	= {}			
		w = View.create_wiget klass, parameters
		if name = parameters[:name]
			wigets[name] = w
		end
		return w
	end
	
	def [] name
		wigets[name]
	end
	
	def []= name, wiget
		wiget.should! :be_a, WGUI::Wiget
		wigets[name] = wiget
	end
	
	def each_editor &b
		wigets.values.each do |w|
			b.call w if w.is_a? Editors::Editor
			w.each_editor &b if w.is_a? View			
		end
	end
	
	def values
		values = {}
		each_editor{|e| e.respond_to :write, values}
		return values
	end
	
	def values= values
		each_editor{|e|	e.respond_to :read, values}
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
		object.should_not! :be_nil
		@wigets = {}
		@root_wrapper = nil
		@inherited = false
		inherit!
		read		
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
	end
	
	def inherit!
		@inherited.should_not! :be_true
		views = self.class.ancestors.select{|a| a.is? View}
		views.reverse.each do |klass|
			block = klass.build_view_get
			block.call self if block
		end
		@inherited = true
	end
	protected :inherit!
	
	def subflow *args
		@root_wrapper.subflow *args
	end
	
	def answer *args
		@root_wrapper.answer *args
	end
	
	def cancel *args
		@root_wrapper.cancel *args
	end
	
	module ClassMethods
		def build_view &b
			build_view_set b
		end
		
		def build_view_get; @build_view end
		
		def build_view_set b; @build_view = b end							
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