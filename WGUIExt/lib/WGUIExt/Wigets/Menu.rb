class Menu < WComponent
	extend Managed
	scope :object
	
	children :@menu
	
	def initialize
		super
#		id = Utils::Extension.get_id(Utils::Extension.get_object)
#		Scope.add_observer id, self, :refresh
	end	
	
	# If there is parent and grandparent
	#   - it lists all parents,  and then all siblings
	#           
	# If there is parent only
	#   - it lists all siblings
	#   
	# If there isn't parent
	#   - it lists all children
	#
	def build				
		object, @menu, @menu2, @current = Utils::Extension.get_object, [], [], nil
		
		counter = -1
		if parent = Utils::Extension.get_parent(object)
			if parent2 = Utils::Extension.get_parent(parent)
				Utils::Extension.each_child parent2 do |e|
					counter += 1
					if e == parent
						@menu << create_link(e)						
						Utils::Extension.each_child parent do |e|
							@menu2 << (counter += 1)
							if e == object
								@menu << create_active_link(e)
								@current = counter
							else
								@menu << create_link(e)
							end                    
						end                        
					else                        
						@menu << create_link(e)
					end
				end
			else
				counter += 1
				@menu << create_link(parent)				
				Utils::Extension.each_child parent do |e|
					@menu2 << (counter += 1)
					if e == object
						@menu << create_active_link(e)
						@current = counter
					else
						@menu << create_link(e)
					end                    
				end									
			end                        			
		else			
			Utils::Extension.each_child object do |e|				
				@menu2 << (counter += 1)
				@menu << create_link(e)
			end
		end				
	end
	
	protected 
	def create_link e
		new :link, :value => e
	end
	
	def create_active_link e
		WLabel.new(Utils::Extension.get_name(e))
	end
end