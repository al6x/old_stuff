class ReferencesBag < Bag
	protected
	def delete_item_method_name
		:delete_reference
	end
	
	def new_item_method_name
		:new_reference
	end
end