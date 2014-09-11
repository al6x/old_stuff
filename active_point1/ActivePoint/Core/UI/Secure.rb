module Secure
	inherit Controller
	
	def object_policy_set
		C.object.should! :be_a, Model::Secure
		
		C.transaction_begin
		form = WebClient::Templates::Select.new
		form.title = "Set Policy"
		form.on_ok = lambda do						
			policy_name = form[:select].value
			raise "Policy not selected!" if policy_name.empty?
			policy = R["Core/Policies"][policy_name]
			R.transaction{
			o = C.object
				o.object_policy = policy
				policy.included_in << o
			}.commit
			view.object = C.object
			view.refresh
		end
		form.on_cancel = lambda{view.cancel}		
		form.parameters = {:values => R["Core/Policies"].policies.collect{|u| u.name}}
		form.object = {:select => ""}
		view.subflow form
	end
	
	def object_policy_delete
		C.transaction_begin
		C.object.should! :be_a, Model::Secure
		
		R.transaction{
			C.object.object_policy = nil
		}.commit
		view.object = C.object
		view.refresh
	end
end