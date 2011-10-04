class ShowSecure < WComponent
	inherit Form
	
	build :attributes do
		object.should! :be_a, Model::Secure
		
		set! :title => `Security`
		
		add `Police`, [
		new(:link, :attr => :object_policy),
		new(:button, :text => `Set`, :action => :object_policy_set)
		]
		
		add `Object Owner`, :link, :attr => :object_owner		
	end
end