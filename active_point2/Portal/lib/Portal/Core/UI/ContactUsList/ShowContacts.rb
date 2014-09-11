class ShowContacts < WComponent
	inherit Form
	
	build :box, :css => "padding" do
		set! :title => `Contacts`
		table :attr => :contacts, :selector => false do
			head do
				string_view :value => UI.to_l("Name")
				string_view :value => UI.to_l("Message")
				string_view :value => ""
			end
			body do
				attributes do
					add UI.to_l("Title"), :string_view, :value => object.title
					add UI.to_l("Name"), :string_view, :value => object.name
					add UI.to_l("e-Mail"), :string_view, :value => object.email
				end
				text_view :value => object.message
				button :text => UI.to_l("Delete"), :action => [:delete_contact, object]
			end
		end
	end
end