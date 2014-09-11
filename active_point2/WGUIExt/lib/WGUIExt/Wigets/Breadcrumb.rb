class Breadcrumb < WComponent
	extend Managed
	scope :object
	
	children :@path
		
	def build
		object = Utils::Extension.get_object		
		path = Utils::Extension.get_path object
		path.should! :be_a, Path
				
		@path = []
		@path << WLabel.new(path.last_name) unless path.empty?
		path = path.previous		
		while path
			unless path.empty?
				o = Utils::Extension.get_object_by_path path
				link = Editors::ObjectLink.new.set! :value => o
				@path << link 
			end
			path = path.previous
		end 				
		
		@path.reverse!
	end
end