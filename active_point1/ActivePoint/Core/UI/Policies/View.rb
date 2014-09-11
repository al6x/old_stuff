class View < WComponent
	inherit UView
	
	build_view do |v|
		form = v.new :box, :style => "float border_left border_top"
		v.root = form
		
		tab = v.new :tab, :active => "Policies", :title => "Policies", :component_id => "policies_tab"
		form.add tab
		tab.add "Policies", build_policies(v)
		tab.add "Permissions", build_permissions(v)		
		tab.add "Details", build_details(v)
	end
	
	class << self
		def build_policies v
			form = v.new :box
			# Controls
			controls = v.new :flow, :style => "minimal color2"		
			form.add controls		
			
			controls.add v.new(:button, :text => "Add", :action => :add_policy)
			unless v.object.policies.empty?
				controls.add v.new(:button, :text => "Delete", :action => [form, :delete_policies])
			end
			
			# Policies
			policy_view = lambda do |u| 
				v.new :reference, :text => u.name, :value => u
			end
			list = v.new :table, :name => :policies,
			:read_values => [:self], :head => ["Name"], :editors => [policy_view]
			form.add list
			form
		end
		
		def build_permissions v
			form = v.new :box
			form.add v.new(:list_view, :name => :permissions)
			form.add v.new(:button, :text => "Edit", :action => :edit_permissions)
			form
		end
		
		def build_details v
			form = v.new :attributes
			
			sp = v.object.default_policy
			editors = [v.new(:reference, :name => :default_policy, :text => (sp ? sp.name : ""))]
			editors << v.new(:button, :text => "Set", :action => :set_default_policy)
			if v.object.default_policy
				editors << v.new(:button, :text => "Delete", :action => :delete_default_policy)
			end
			form.add "Default Police", editors
			form
		end
	end
end