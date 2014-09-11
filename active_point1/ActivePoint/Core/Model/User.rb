class User
	inherit Entity
	
	metadata do
		attribute :password, :string
		attribute :avatar, :data
		attribute :details, :object, :initialize => lambda{WGUIExt::Editors::RichTextData.new}
		reference :included_in, :bag
		
		validate do
			raise "Empty Name!" if name.empty?			
		end
	end
	
	alias_method :name, :entity_id
	alias_method :name=, :entity_id=
	
	def groups
		groups = Set.new
		included_in.each do |group| 
			groups = groups.merge group.all_groups
		end
		return groups.map{|group| group.name}
	end
	
	def permissions policy
		permissions = {}
		groups = self.groups
		policy.each do |permission_name, groups_to_perm|					
			permissions[permission_name] = false
			groups.each do |group|
				if group_to_perm[group]
					permissions[permission_name] = true
					break
				end
			end							
		end
		return permissions
	end
	
	def can? permission_name, policy
		groups_to_perm = policy[permission_name]
		return false unless groups_to_perm
		
		groups.each do |group|
			return true if groups_to_perm[group]
		end
		
		return false
	end
end