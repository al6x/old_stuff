class AnonymousUser < User
	ID = "AnonymousUser"
	
	metadata do
#		before :commit do
#			raise "Forbiden to modify AnonymousUser, it's System User!" if R.om_id_include? ID
#		end
	end
end