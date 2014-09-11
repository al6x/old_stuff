class Breadcrumb < WComponent
	extend Managed
	scope :object
	inject :object => :object, :portlet => Engine::Window
	
	children :@path
	
	def initialize    
		super
		path = Extension.get_path object
		@path = []
		@path << WLabel.new(path.last_name) unless path.empty?
		path = path.previous		
		while path
			unless path.empty?
				link = WLink.new(path.last_name, path).set :portlet => portlet
				@path << link 
			end
			path = path.previous
		end 				
		
		@path.reverse!
	end
end