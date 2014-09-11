class DefaultView < WComponent
	def initialize
		super()
		
		@env_lbl = WLabel.new.set :preformatted => true
		@env_btn = WLinkButton.new "Your Environment" do
			if @env_visible
				@env_visible = false
				@env_lbl.text = ""
			else
				@env_lbl.text = env_get
				@env_visible = true
			end						
		end
	end		
	
	def object= o	
		@object = o
	end
	
	protected
	def env_get
		"""\
ActivePoint::CONFIG #{::ActivePoint::CONFIG.inspect}
ObjectModel::CONFIG #{::ObjectModel::CONFIG.inspect}
WGUI::CONFIG #{::WGUI::CONFIG.inspect}"""
	end
end