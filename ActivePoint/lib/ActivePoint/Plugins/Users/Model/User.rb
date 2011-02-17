class User
	inherit Entity
	
	ANONYMOUS = "Anonymous"
	ADMINISTRATOR = "admin"
	
	metadata do
		name "User"
		
		attribute :password, :string
		attribute :avatar, :data
		attribute :details, :richtext
		reference :included_in, :bag
		
		validate do
			raise "Empty Name!" if name.empty?			
		end
	end
	
	def groups
		groups = Set.new
		included_in.each do |group| 
			groups = groups.merge group.all_groups
		end
		return groups
	end		
	
	def anonymous?
		name == ANONYMOUS
	end
	
	def administrator?
		name == ADMINISTRATOR
	end
end