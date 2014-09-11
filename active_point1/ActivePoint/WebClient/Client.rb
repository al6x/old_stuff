class Client < WComponent
	include WPortlet
	extend Managed	
	scope :session 
	
	inject :ap_controller => ActivePoint::Engine::APController
	
	children :content
	
	attr_accessor :skin
	
	def initialize
		super
		self.component_id = "object"
		self.layout = nil
		self.exclusive = false
		
		@view_wrapper = WGUIExt::Containers::Wrapper.new.set :component => :controller, :accessor => :view				
	end
	
	def exclusive= wiget				
		wiget.should! :be_a, [NilClass, WGUI::Wiget]
		@exclusive = wiget
		refresh
	end
	
	def exclusive?
		@exclusive != nil
	end
	
	def state= path		
		return if exclusive?
		path = if R.include? path
			path
		else
			R.should! :include, CONFIG[:default_object]
			CONFIG[:default_object]
		end
		ap_controller.object = R[path]
	end	
	
	def state
		if o = ap_controller.object 
			o.entity_path
		else
			R.should! :include, CONFIG[:default_object]
			o = R[CONFIG[:default_object]]
			ap_controller.object = o
			o.entity_path
		end
	end		
	
	def layout= layout
		layout.should! :be_a, [WGUI::Wiget, NilClass]
		return if @layout == layout
		@layout = layout
		refresh
	end
	
	def content
		if @exclusive
			@exclusive
		elsif @layout
			@layout
		else
			@view_wrapper
		end
	end	
		
	def self.state_conversion_strategy; WGUI::Engine::State::RelativePathStateConversionStrategy end		
end		