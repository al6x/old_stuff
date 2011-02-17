class ContactUsList
	inherit Controller
	
	def show
		@view = ShowContacts.new.set :object => C.object
	end
	
	def delete_contact contact
		R.transaction{contact.delete}.commit
		show
	end
end