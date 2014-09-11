class Group
	inherit Entity
	
	metadata do
		reference :included_in, :bag
		reference :groups, :bag
		reference :users, :bag
		
		before :new_reference, :check_reference_uniqity
		
		validate do
			raise "Empty Name!" if name.empty?			
		end
	end	
	
	alias_method :name=, :entity_id=
	alias_method :name, :entity_id
	
	def check_reference_uniqity attr_name, new
		case attr_name
			when :groups then raise "Can't add Group twice!" if groups.include? new				
			when :users then raise "Can't add User twice!" if users.include? new
		end
	end
	
	def all_groups
		all = Set.new
		all.add self
		included_in.each{|group| all.merge! group.all_groups}
		return all
	end
end