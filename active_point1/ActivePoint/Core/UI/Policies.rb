class Policies
	inherit Controller
	
	def initialize
		@view = View.new
		@view.object = C.object
	end
	
	def add_policy
		new_policy = nil
		C.transaction_begin
		R.transaction{new_policy = Model::Policy.new}
		form = Policy::Edit.new
		form.on_ok = lambda do					
			R.transaction{
				new_policy.set form.values				
				new_policy.validate
				raise "Not Unique Name!" if C.object.policies.any?{|pl| pl.name == new_policy.name}
				
				C.object.policies << new_policy
			}.commit	
			@view.object = C.object
			@view.refresh
		end
		form.on_cancel = lambda{@view.cancel}
		form.object = new_policy
		@view.subflow form
	end
	
	def delete_policies
		C.transaction_begin
		R.transaction{
			@view[:policies].selected.every.delete #each{|om_id| R.by_id(om_id).delete}
		}.commit
		@view.object = C.object
		@view.refresh
	end		
	
	def edit_permissions
		C.transaction_begin
		form = WebClient::Templates::Select.new
		form.title = "Edit Roles"
		form.on_ok = lambda do						
			R.transaction{C.object.permissions = form.values[:select]}.commit
			view.object = C.object
			view.refresh
		end
		form.on_cancel = lambda{view.cancel}		
		
		form.parameters = {:modify => true, :multiple => true}
		form.object = {:select => C.object.permissions}
		
		view.subflow form
	end
	
	def set_default_policy
		C.transaction_begin
		form = WebClient::Templates::Select.new
		form.title = "Set Policy"
		form.on_ok = lambda do						
			policy_name = form[:select].value
			raise "Policy not selected!" if policy_name.empty?
			policy = R["Core/Policies"][policy_name]
			R.transaction{C.object.default_policy = policy}.commit
			view.object = C.object
			view.refresh
		end
		form.on_cancel = lambda{view.cancel}		
		form.parameters = {:values => R["Core/Policies"].policies.collect{|u| u.name}}
		form.object = {:select => ""}
		view.subflow form
	end
	
	def delete_default_policy
		R.transaction{C.object.default_policy = nil}.commit
		view.object = C.object
		view.refresh
	end
end