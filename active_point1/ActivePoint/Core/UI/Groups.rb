class Groups
	inherit Controller
	
	def initialize
		@view = GroupsList.new
		@view.object = C.object
	end
	
	def add_group
		C.transaction_begin
		new_group = nil		
		R.transaction{new_group = Model::Group.new}
		form = Group::Edit.new
		form.on_ok = lambda do					
			R.transaction{
				new_group.set form.values				
				new_group.validate				
				raise "Not Unique Name!" if C.object.groups.any?{|g| g.name == new_group.name}
				
				C.object.groups << new_group
			}.commit	
			@view.object = C.object
			@view.refresh
		end
		form.on_cancel = lambda{@view.cancel}
		form.object = new_group
		@view.subflow form
	end
	
	def delete_groups
		C.transaction_begin
		R.transaction{
			@view[:groups].selected.every.delete #each{|om_id| R.by_id(om_id).delete}
		}.commit
		@view.object = C.object
		@view.refresh
	end
end