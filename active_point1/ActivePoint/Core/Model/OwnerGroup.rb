# Special Owner Group
class OwnerGroup < Group
	ID = "OwnerGroup"
	
	metadata do
		before :commit do
			raise "Forbiden to modify Owner, it's System Group!" if R.om_id_include? ID
		end
	end
end