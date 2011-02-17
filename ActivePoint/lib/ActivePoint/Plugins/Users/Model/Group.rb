class Group
	inherit Entity
	
	ANONYMOUS = "AnonymousGroup"
#	OWNER = "OwnerGroup"
#	ADMINISTRATORS = "AdministratorsGroup"
	
	metadata do
		name "Group"
		
		reference :included_in, :bag
		reference :groups, :bag
		reference :users, :bag
		
		before :new_reference, :check_reference_uniqity
		
		validate do
			raise "Empty Name!" if name.empty?			
		end
	end	
	
	def check_reference_uniqity attr_name, new
		case attr_name
			when :groups then raise "Can't add Group twice!" if groups.include? new				
			when :users then raise "Can't add User twice!" if users.include? new
		end
	end
	
	def add_user user
		users << user
		user.included_in << self
	end
	
	def delete_user user
		users.delete user
		user.included_in.delete self
	end
	
	def add_group group
		groups << group
		group.included_in << self
	end
	
	def delete_group group
		groups.delete group
		group.included_in.delete self
	end
	
	def all_groups
		all = Set.new
		all.add self
		included_in.each{|group| all.merge! group.all_groups}
		return all
	end
end