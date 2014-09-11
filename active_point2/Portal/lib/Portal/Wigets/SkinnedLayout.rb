class SkinnedLayout < WComponent
	AREAS = [:site_menu, :user_menu, :context_menu, :message, :center]
	
	attr_accessor *AREAS
	children *AREAS.collect{|name| :"@#{name}_wiget"}
	
	def build
		AREAS.each do |name|
			wiget_name = self.send name
			next unless wiget_name
			
			wiget_name.should! :be_a, String
			R.by_id("Core")["Wigets"].should! :include?, wiget_name
			
			wiget_def = R.by_id("Core")["Wigets"][wiget_name]
			wiget = wiget_def.build_wiget
			
			self.instance_variable_set "@#{name}_wiget", wiget
		end
	end
end