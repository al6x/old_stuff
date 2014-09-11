class TreeMenu < WComponent
	extend Managed
	scope :object
	inject :object => :object, :window => WGUI::Engine::Window, :storage => :storage,
	:portlet => WebClient::Engine::Window
	
	children :@links
	
	class Meta
		attr_accessor :current, :level, :has_children, :opened, :parent_index
	end
	
	def source
		storage["Home/Core/Tools/TreeMenu/Menu"]
	end
	
	def build
		@links, @to_link = [], {}
		source.each(:children) do |item|									
			create_link item
			item.each(:children) do |item2|				
				create_link item2
			end						
		end		
	end
	
	protected
	def create_link item
		w = if object == item.link
			WLabel.new(item.link.name)
		else
			WLink.new(item.link.name, item.link.path).set(:portlet => portlet)
		end
		@links << w
		@to_link[item] = w
	end
	
	#	
	#	# If there is parent and grandparent
	#	#   - it lists all parents,  and then all siblings
	#	#           
	#	# If there is parent only
	#	#   - it lists all siblings
	#	#   
	#	# If there isn't parent
	#	#   - it lists all children
	#	#
	#	def initialize				
	#		super
	#		object, @menu, @menu2, @current = self.object, [], [], nil
	#		
	#		counter = -1
	#		if parent = Menu.parent_get.call(object)			            
	#			if parent2 = Menu.parent_get.call(parent)
	#				object_each_child parent2 do |e|
	#					counter += 1
	#					if e == parent
	#						@menu << WLink.new(Menu.name_get.call(e), Extension.get_path(e)).set(:portlet => portlet)
	#						
	#						object_each_child parent do |e|
	#							@menu2 << (counter += 1)
	#							if e == object
	#								@menu << WLabel.new(Menu.name_get.call(e))
	#								@current = counter
	#							else
	#								@menu << WLink.new(Menu.name_get.call(e), Extension.get_path(e)).set(:portlet => portlet)
	#							end                    
	#						end                        
	#					else                        
	#						@menu << WLink.new(Menu.name_get.call(e), Extension.get_path(e)).set(:portlet => portlet)
	#					end
	#				end
	#			else
	#				counter += 1
	#				@menu << WLink.new(parent.name, Extension.get_path(parent)).set(:portlet => portlet)				
	#				object_each_child parent do |e|
	#					@menu2 << (counter += 1)
	#					if e == object
	#						@menu << WLabel.new(Menu.name_get.call(e))
	#						@current = counter
	#					else
	#						@menu << WLink.new(Menu.name_get.call(e), Extension.get_path(e)).set(:portlet => portlet)
	#					end                    
	#				end									
	#			end                        			
	#		else			
	#			object_each_child object do |e|				
	#				@menu2 << (counter += 1)
	#				@menu << WLink.new(Menu.name_get.call(e), Extension.get_path(e)).set(:portlet => portlet)                
	#			end
	#		end
	#	end
	#	
	#	def object_each_child object, &b
	#		Menu.each_child.call object, b	
	#	end
	#	
	#	class << self
	#		attr_accessor :parent_get, :each_child, :name_get
	#	end
end

dir = File.dirname __FILE__
klass = TreeMenu
Scope[WGUI::Engine::StaticResource].add_file "#{klass}/opened.png", "#{dir}/opened.png" 
Scope[WGUI::Engine::StaticResource].add_file "#{klass}/closed.png", "#{dir}/closed.png" 
