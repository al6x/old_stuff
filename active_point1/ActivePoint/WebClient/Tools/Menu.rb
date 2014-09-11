class Menu < WComponent
	extend Managed
	scope :object
	inject :object => :object, :portlet => Engine::Window
	
	children :@menu
	
	# If there is parent and grandparent
	#   - it lists all parents,  and then all siblings
	#           
	# If there is parent only
	#   - it lists all siblings
	#   
	# If there isn't parent
	#   - it lists all children
	#
	def initialize				
		super
		object, @menu, @menu2, @current = self.object, [], [], nil
		
		counter = -1
		if parent = Menu.parent_get.call(object)			            
			if parent2 = Menu.parent_get.call(parent)
				object_each_child parent2 do |e|
					counter += 1
					if e == parent
						@menu << WLink.new(Menu.name_get.call(e), Extension.get_path(e)).set(:portlet => portlet)
						
						object_each_child parent do |e|
							@menu2 << (counter += 1)
							if e == object
								@menu << WLabel.new(Menu.name_get.call(e))
								@current = counter
							else
								@menu << WLink.new(Menu.name_get.call(e), Extension.get_path(e)).set(:portlet => portlet)
							end                    
						end                        
					else                        
						@menu << WLink.new(Menu.name_get.call(e), Extension.get_path(e)).set(:portlet => portlet)
					end
				end
			else
				counter += 1
				@menu << WLink.new(parent.name, Extension.get_path(parent)).set(:portlet => portlet)				
				object_each_child parent do |e|
					@menu2 << (counter += 1)
					if e == object
						@menu << WLabel.new(Menu.name_get.call(e))
						@current = counter
					else
						@menu << WLink.new(Menu.name_get.call(e), Extension.get_path(e)).set(:portlet => portlet)
					end                    
				end									
			end                        			
		else			
			object_each_child object do |e|				
				@menu2 << (counter += 1)
				@menu << WLink.new(Menu.name_get.call(e), Extension.get_path(e)).set(:portlet => portlet)                
			end
		end
	end
	
	def object_each_child object, &b
		Menu.each_child.call object, b	
	end
	
	class << self
		attr_accessor :parent_get, :each_child, :name_get
	end
end