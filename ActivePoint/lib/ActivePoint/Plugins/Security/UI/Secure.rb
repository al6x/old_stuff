module Secure	
	inherit Controller
	
	def object_policy_set
		restore = @view
		R.transaction_begin
		@view = Form.common_dialog do
			add nil, :select, :attr => :value, :values => object[:values]
		end
		@view.on[:ok] = lambda do						
			policy_name = @view[:value].value
			policy = unless policy_name.empty?
				R.by_id("Security")[policy_name]
			else
				policy = nil
			end
			R.transaction{C.object.set_policy policy}.commit
			@view = restore
			@view.object = C.object
		end
		@view.on[:cancel] = lambda{@view = restore; @view.refresh}		
		values = R.by_id("Security").policies.collect{|u| u.name}
		values << ""
		value = C.object.object_policy ? C.object.object_policy.name : ""
		@view.object = {
			:value => value, :values => values,
			:title => ActivePoint::Plugins::Security::UI.to_l("Set Policy")
		}
	end
	
	secure :object_policy_set => :manage
end