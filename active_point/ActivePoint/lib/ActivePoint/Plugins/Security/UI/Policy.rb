class Policy	
	inherit Controller
	editor EditPolicy
	
	def show
		@view = ShowPolicy.new.set :object => C.object
	end
	
	def edit_policy
		R.transaction_begin
		@view = EditPolicy.new.set :object => C.object
		@view.on[:ok] = lambda do						
			R.transaction{C.object.set @view.values}.commit
			show
		end
		@view.on[:cancel] = lambda{show}
	end
	
	def edit_map
		R.transaction_begin
		@view = EditMap.new
		@view.on[:ok] = lambda do									
			map = Policy.matrix_to_map @view.object[:head], @view.table.collect_values
			R.transaction{C.object.map = map}.commit
			show
		end
		@view.on[:cancel] = lambda{show}
		head, matrix = Policy.map_to_matrix C.object.map		
		@view.object = {:head => head, :matrix => matrix}
	end
	
	def edit_groups
		groups = @view.object[:head]
		restore = @view
		
		@view = Form.common_dialog do
			add nil, :select, :attr => :value, :values => object[:values], :multiple => true
		end
		
		@view.on[:ok] = lambda do								
			new_groups = @view.values[:value]
			new_groups.unshift ""
			matrix = restore.table.collect_values
			to_add, to_delete = new_groups - groups, groups - new_groups			
			indexes_to_delete = to_delete.collect{|group| groups.index(group)}
			indexes_to_delete.sort!.reverse!
			
			groups = (groups - to_delete) + to_add
			matrix.each do |row|
				indexes_to_delete.each{|i| row.delete_at(i)}
				to_add.each{|group| row << ""}
			end
			
			@view = restore
			@view.object = {:head => groups, :matrix => matrix}
		end
		@view.on[:cancel] = lambda{@view = restore; @view.refresh}
		
		values = R.by_id("Users").groups.map{|g| g.name}
		@view.object = {:value => groups[1..groups.size], :title => `Edit Groups`, :values => values}
	end
	
	def edit_roles
		restore = @view
		
		@view = Form.common_dialog do
			add nil, :select, :attr => :value, :values => object[:values], :multiple => true
		end

		matrix = restore.table.collect_values
		roles = matrix.collect{|row| row[0]}
		@view.on[:ok] = lambda do							
			head = restore.object[:head]												
			new_roles = @view.values[:value]			
			to_add, to_delete = new_roles - roles, roles - new_roles
						
			matrix.delete_if{|row| to_delete.include? row[0]}
			to_add.each do |r|
				row = [r]
				(head.size - 1).times{row << ""}
				matrix << row
			end
			matrix.each{|row| new_roles.size.times{row << ""}}
			
			@view = restore
			@view.object = {:head => head, :matrix => matrix}
		end
		@view.on[:cancel] = lambda{@view = restore; @view.refresh}		
		
		@view.object = {:value => roles, :title => `Edit Roles`, :values => R.by_id("Security").roles.collect{|r| r.name}}
	end
	
	class << self
		def map_to_matrix map
			head, matrix = [""], []
			all_groups = []
			map.each{|role_id, groups| all_groups += groups.keys}
			all_groups = all_groups.uniq.sort
			
			head += all_groups.collect{|group_id| R.by_id(group_id).name}
			map.each do |role_id, groups| 
				role_name = R.by_id(role_id).name
				row = [role_name]
				all_groups.each do |group_id| 
					value = groups[group_id]
					if value == true
						row << `yes`
					elsif value == false
						row << `no`
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
				roles = {}
				role_id = R.by_id("Security")[row[0]].entity_id
				map[role_id] = roles
				row.each_with_index do |cell, index|
					next if index == 0						
					
					group_name = head[index].should_not! :be_nil
					group_id = R.by_id("Users")[group_name].entity_id
					value = if cell == `yes`
						roles[group_id] = true
					elsif cell == `no`
						roles[group_id] = false
					else
						cell.should! :==, ""
					end										
				end
			end
			
#			map.delete_if{|key, value| value.empty?}
			
			return map
		end
	end
end