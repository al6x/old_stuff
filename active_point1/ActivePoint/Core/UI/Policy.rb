class Policy	
	inherit Controller
	
	def initialize
		@view = View.new
		@view.object = C.object
	end
	
	def edit_policy
		C.transaction_begin
		form = Edit.new
		form.on_ok = lambda do						
			R.transaction{
				o = C.object
				o.set form.values
			}.commit
			@view.object = C.object
			@view.refresh
		end
		form.on_cancel = lambda{@view.cancel}
		form.object = C.object		
		@view.subflow form
	end
	
	def edit_map
		C.transaction_begin
		@edit_map = EditMap.new
		@edit_map.on_ok = lambda do						
			table = @edit_map.table			
			map = Policy.matrix_to_map table.head, table.collect_values			
			R.transaction{C.object.map = map}.commit
			@view.object = C.object
			@view.refresh
			@edit_map = nil
		end
		@edit_map.on_cancel = lambda do 
			@view.cancel
			@edit_map = nil
		end
		head, matrix = Policy.map_to_matrix C.object.map		
		@edit_map.object = {:head => head, :matrix => matrix}
		@view.subflow @edit_map
	end
	
	def edit_groups
		@edit_map.should_not! :be_nil
		groups = @edit_map.table.head
		
		form = WebClient::Templates::Select.new
		form.title = "Edit Roles"
		form.on_ok = lambda do								
			new_groups = form.values[:select]
			new_groups.unshift ""
			matrix = @edit_map.table.collect_values
			to_add, to_delete = new_groups - groups, groups - new_groups			
			indexes_to_delete = to_delete.collect{|group| groups.index(group)}
			indexes_to_delete.sort!.reverse!
			
			groups = (groups - to_delete) + to_add
			matrix.each do |row|
				indexes_to_delete.each{|i| row.delete_at(i)}
				to_add.each{|group| row << ""}
			end
			
			@edit_map.object = {:head => groups, :matrix => matrix}
			@edit_map.refresh
		end
		form.on_cancel = lambda{@edit_map.cancel}		
		
		form.parameters = {:multiple => true, :values => R["Core/Groups"].groups.map{|g| g.name}}
		form.object = {:select => groups[1..groups.size]}
		
		@edit_map.subflow form
	end
	
	def edit_permissions
		@edit_map.should_not! :be_nil
		
		form = WebClient::Templates::Select.new
		form.title = "Edit Permissions"
		matrix = @edit_map.table.collect_values
		permissions = matrix.collect{|row| row[0]}
		form.on_ok = lambda do							
			head = @edit_map.table.head
			new_permissions = form.values[:select]			
			to_add, to_delete = new_permissions - permissions, permissions - new_permissions
						
			matrix.delete_if{|row| to_delete.include? row[0]}
			to_add.each do |perm|
				row = [perm]
				(head.size - 1).times{row << ""}
				matrix << row
			end
			matrix.each{|row| new_permissions.size.times{row << ""}}
			
			@edit_map.object = {:head => head, :matrix => matrix}
			@edit_map.refresh
		end
		form.on_cancel = lambda{@edit_map.cancel}		
		
		form.parameters = {:multiple => true, :values => R["Core/Policies"].permissions}
		form.object = {:select => permissions}
		
		@edit_map.subflow form
	end
	
	class << self
		def map_to_matrix map
			head, matrix = [""], []
			all_groups = []
			map.each{|permission, groups| all_groups += groups.keys}
			all_groups = all_groups.uniq.sort
			
			head += all_groups
			map.each do |permission, groups| 
				row = [permission]
				all_groups.each do |group| 
					value = groups[group]
					if value == true
						row << "yes"
					elsif value == false
						row << "no"
					else
						row << ""
					end
				end
				matrix << row				
			end
			
			return head, matrix
		end
		
		def matrix_to_map head, matrix
			map = {}
			matrix.each do |row|
				row.size.should! :>, 0				
				permissions = {}
				map[row[0]] = permissions
				row.each_with_index do |cell, index|
					next if index == 0						
					
					group = head[index].should_not! :be_nil
					value = if cell == "yes"
						permissions[group] = true
					elsif cell == "no"
						permissions[group] = false
					else
						cell.should! :==, ""
					end										
				end
			end
			
			map.delete_if{|key, value| value.empty?}
			
			return map
		end
	end
end