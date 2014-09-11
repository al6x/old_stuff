module View
	inherit UView
	
	build_view do |v|
		form = v.new :attributes, :title => "Security"
		v.aspects.add form
		
		v.object.should! :be_a, Model::Secure
		sp = v.object.object_policy
		editors = [v.new(:reference, :name => :object_policy, :text => (sp ? sp.name : ""))]
		editors << v.new(:button, :text => "Set", :action => :object_policy_set)
		if v.object.object_policy
			editors << v.new(:button, :text => "Delete", :action => :object_policy_delete)
		end
		form.add "Security Police", editors
		
		oo = v.object.object_owner
		form.add "Object Owner", v.new(:reference, :name => :object_owner, :text => (oo ? oo.entity_id : ""))
	end
end