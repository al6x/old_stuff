class AnonymousGroup < Group
	ID = "AnonymousGroup"
	
	metadata do
#		before :commit do
#			raise "Forbiden to modify AnonymousGroup, it's System Group!" if R.om_id_include? ID
#		end
	end
end