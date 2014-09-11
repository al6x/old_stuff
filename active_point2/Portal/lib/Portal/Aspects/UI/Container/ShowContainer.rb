class ShowContainer < WComponent
	inherit Form
	
	def initialize parent_form
		super()
		parent_form.aspects[:container] = self
	end
	
	build :box, :css => "padding" do
		line :wide => false do
			button :text => Portal::Aspects.to_l("Add"), :action => :container_add
			button :text => Portal::Aspects.to_l("Delete"), :action => [form, :container_delete] unless object.items.empty?
		end
		table :attr => :items, :selector => true do
			head do
				string_view :value => Portal::Aspects::UI.to_l("Name")
				string_view :value => Portal::Aspects::UI.to_l("Type")
			end
			body do
				link :value => object
				string_view :value => object.meta.name
			end
		end		
	end
end