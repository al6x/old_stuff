class Resource
	extend Managed
	scope :application
	inject :window => Window
	
	# Synchronization not needed, it isn't thread safe, but it performs only READ operations, so it doesn't 
	# change shared resources.
	# And if error will occurs it just throw an exception, this isn't critical.
	def get_resource component_id		
		res = window.content.visit(Visitors::FindResource.new(component_id)).result
        raise "Resource with component_id = '#{component_id}' not found!" unless res
		access_check res		
		return res			
	end			
	
	def access_check resource
		raise "Can't show invisible resource '#{resource.component_id}'!" unless resource.visible?
    end
end