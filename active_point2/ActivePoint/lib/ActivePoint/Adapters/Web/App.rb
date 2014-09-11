class App < WComponent
	include WPortlet
	extend Managed	
	scope :session 
	
	inject :app_controller => AppController
	
	children :content
	
	attr_accessor :skin
	attr_reader :layout, :exclusive
	
	def initialize
		super
		self.component_id = "object"
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
		app_controller.object = R[path]
		refresh
	end	
	
	def state
		if o = app_controller.object 
			o.path
		else
			R.should! :include, CONFIG[:default_object]
			o = R[CONFIG[:default_object]]
			app_controller.object = o
			o.path
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
			@exclusive_layout ||= ExclusiveLayout.new
		elsif @layout
			@layout
		else
			@default_layuot ||= DefaultLayout.new
		end
	end	
		
	def self.state_conversion_strategy; WGUI::Engine::State::RelativePathStateConversionStrategy end		
end		