class Security
	inherit Controller
	
	def show
		@view = ShowSecurity.new.set :object => C.object
	end
	
	def add_policy
		new_policy = nil
		R.transaction_begin
		R.transaction{new_policy = Model::Policy.new}
		@view = C.editor_for(new_policy).set :object => new_policy
		@view.on[:ok] = lambda do					
			R.transaction{
				new_policy.set @view.values				
				new_policy.validate
				raise `Not Unique Name!` if C.object.policies.any?{|pl| pl.name == new_policy.name}
				
				C.object.policies << new_policy
			}.commit	
			show
		end
		@view.on[:cancel] = lambda{show}
	end
	
	def delete_policies
		R.transaction_begin
		R.transaction{@view[:policies].selected.every.delete}.commit
		show
	end		
	
	def add_role
		new_role = nil
		R.transaction_begin
		R.transaction{new_role = Model::Role.new}
		@view = C.editor_for(new_role).set :object => new_role
		@view.on[:ok] = lambda do					
			R.transaction{
				new_role.set @view.values				
				new_role.validate
				raise `Not Unique Name!` if C.object.roles.any?{|r| r.name == new_role.name}
				
				C.object.roles << new_role
			}.commit	
			show
		end
		@view.on[:cancel] = lambda{show}
	end
	
	def delete_roles
		R.transaction_begin
		R.transaction{@view[:roles].selected.every.delete}.commit
		show
	end		
	
	def edit_permissions
		R.transaction_begin
		@view = Form.common_dialog do
			add nil, :select, :attr => :value, :values => object[:values],
			:modify => true, :multiple => true
		end
		@view.on[:ok] = lambda do						
			R.transaction{C.object.permissions = @view[:value].value}.commit
			show
		end
		@view.on[:cancel] = lambda{show}	
		@view.object = {:value => C.object.permissions, :values => C.object.permissions, 
		:title => `Edit Roles`}
	end
	
	def set_default_policy
		R.transaction_begin
		@view = Form.common_dialog do
			add nil, :select, :attr => :value, :values => object[:values]
		end
		@view.on[:ok] = lambda do						
			policy_name = @view[:value].value
			policy = unless policy_name.empty?
				policy = R.by_id("Security")[policy_name]
			else
				nil
			end
			R.transaction{C.object.default_policy = policy}.commit
			show
		end
		@view.on[:cancel] = lambda{show}		
		values = R.by_id("Security").policies.collect{|u| u.name}
		values << ""
		@view.object = {:value => "", :values => values, :title => `Edit Default Policy`}
	end
end