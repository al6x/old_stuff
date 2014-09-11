class SiteLayout < WComponent
	attr_accessor :map, :left, :top, :right, :bottom, :center
	
	children :@wmap, :@wleft, :@wtop, :@wright, :@wbottom, :@wcenter, :@wobject_view
	
	def after_object_set
		refresh	
	end
	
	def get_map key
		index = @map_names.index(key)
		index ? @wmap[index] : nil
	end
	
	def build
		@site = C.object.search_up{|o| o.is_a? Model::Site}.should_not! :be_nil
		
		@wmap, @wleft, @wtop, @wright, @wbottom, @wcenter	= [], [], [], [], [], []
		@map_names = []
		
		# Map
		if map
			map.should! :be_a, Hash
			map.each do |name, path|
				name.should! :be_a, Symbol
				path.should! :be_a, String
				R.should! :include, path
				
				wiget_def = R[path]
				@wmap << wiget_def.create_wiget_wrapper
				@map_names << name
			end
		end
		
		# Areas
		[:left, :top, :right, :bottom, :center].each do |area|
			value = send area
			next unless value
			value.should! :be_a, Array
			list = instance_variable_get "@w#{area}"
			value.each do |path|
				path.should! :be_a, String
				R.should! :include, path
				
				wiget_def = R[path]
				list << wiget_def.create_wiget_wrapper				
			end
		end
		
		# ObjectView
		@wobject_view = WGUIExt::Containers::Wrapper.new.set \
		:component => :controller, :accessor => :view		
		
		# Logo
		#		if home_path
		#			R.should! :include?, home_path
		#			@logo = new :link, :text => site.logo, :value => R[home_path]
		#		else
		#			@logo = WLabel.new site.logo
		#		end
	end
end