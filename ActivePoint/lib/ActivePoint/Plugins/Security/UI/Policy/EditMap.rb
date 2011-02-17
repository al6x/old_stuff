class EditMap < WComponent
	inherit Form
	attr_accessor :table
	
	def initialize
		super
	end
	
	build :box, :css => "padding" do
		set! :title => `Edit Security Map`
		
		line :wide => false do
			button :text => `Edit Groups`, :action => [form, :edit_groups]
			button :text => `Edit Roles`, :action => [form, :edit_roles]
		end
		
		head_values = object[:head]
				
		form.table = table :selector => false, :value => object[:matrix] do
			head do
				head_values.each do |value|
					string_view :value => value
				end
			end
			
			body do
				string_view :value => object[0]
				
				(head_values.size - 1).times do |i|
					select :value => object[i + 1], :values => [
					ActivePoint::Plugins::Security::UI.to_l("yes"), 
					ActivePoint::Plugins::Security::UI.to_l("no"), 
					""
					]
				end
			end
		end
		
		line :wide => false do
			button :text => `Ok`, :action => [form, on[:ok]]
			button :text => `Cancel`, :action => on[:cancel]
		end
	end
end