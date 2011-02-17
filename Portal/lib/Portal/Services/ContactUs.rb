class ContactUs		
	extend Configurator
	
	depends_on ::Portal::Core
	
	startup do
		Scope[:services][:contact_us] = ContactUs.new
	end
	
	def contact_us		
		R.transaction_begin
		contact = nil
		R.transaction{contact = Core::Model::ContactUs.new}
		
		form = ContactUsForm.new.set :object => contact
		form.on[:ok] = lambda do					
			R.transaction{
				contact.set form.values								
				R.by_id("Contact Us").contacts << contact
			}.commit	
			C.messages.info `Message has been sent!`
			C.app.exclusive = nil
		end
		form.on[:cancel] = lambda{C.app.exclusive = nil}
		C.app.exclusive = form
	end
end