class ChildrenBag < Bag
	protected
	def delete_item_method_name
		:delete_child
	end
	
	def new_item_method_name
		:new_child
	end
end