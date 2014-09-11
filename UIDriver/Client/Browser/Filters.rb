class Filters
	INFINITY = 1_000_000
	
	def initialize browser
		@browser = browser
	end
	
	def left *args
		minimize lambda{|pos| pos.left}, *args
	end		
	
	def top *args
		minimize lambda{|pos| pos.top}, *args
	end
	
	def right *args
		minimize lambda{|pos| -pos.right}, *args
	end
	
	def bottom *args
		minimize lambda{|pos| -pos.bottom}, *args
	end
	
	def center_x list
		return list if list.empty?
		
		left = left(list).first.left
		right = right(list).first.left
		mediana = left + (right - left)/2
		
		# Distance between Mediana and Element Center X
		minimize lambda{|pos| (mediana - pos.center_x).abs}, list			
	end
	
	def center_y list
		return list if list.empty?
		
		top = top(list).first.top
		bottom = bottom(list).first.bottom
		mediana = top + (bottom - top)/2
		
		# Distance between Mediana and Element Center Y
		minimize lambda{|pos| (mediana - pos.center_y).abs}, list
	end
	
	def center list
		list.filter(:center_x).filter(:center_y)
	end
	
	def inside list, scope
		scope.should! :be_a, ResultSet				
		
		rs = Browser::ResultSet.new @browser			
		result = list.find_all{|pos| scope.any?{|spos| pos.inside_of? spos}}
		rs.replace result 
		return rs
	end
	
	def near *args
		func = lambda do |pos, object_pos| 
			if pos != object_pos
				pos.distance(object_pos)
			else
				INFINITY
			end
		end
		minimize_distance func, *args
	end
	
	def left_of *args		
		func = lambda do |pos, object_pos| 
			dist = object_pos.left - pos.right
			if pos.intersect_y?(object_pos) and dist >= 0 and pos != object_pos
				dist
			else
				INFINITY
			end
		end
		minimize_distance func, *args
	end
	
	def top_of *args
		func = lambda do |pos, object_pos| 
			dist = object_pos.top - pos.bottom
			if pos.intersect_x?(object_pos) and dist >= 0 and pos != object_pos
				dist
			else
				INFINITY
			end
		end
		minimize_distance func, *args
	end
	
	def right_of *args
		func = lambda do |pos, object_pos| 
			dist = pos.left - object_pos.right
			if pos.intersect_y?(object_pos) and dist >= 0 and pos != object_pos
				dist
			else
				INFINITY
			end
		end
		minimize_distance func, *args
	end
	
	def bottom_of *args
		func = lambda do |pos, object_pos| 
			dist = pos.top - object_pos.bottom
			if pos.intersect_x?(object_pos) and dist >= 0 and pos != object_pos
				dist
			else
				INFINITY
			end
		end
		minimize_distance func, *args
	end
	
	def cell list, col, row
		col.should!(:be_a, ResultSet).size.should!(:==, 1)
		row.should!(:be_a, ResultSet).size.should!(:==, 1)
		
		col, row = col.first, row.first				
		cell = Position.new "", [col.left, row.top, col.width, row.height]
		
		func = lambda do |pos| 						
			if pos.intersect? cell
				# Distance between Cell center and Element
				((pos.center_x - col.center_x)**2 + (pos.center_y - row.center_y)**2)**0.5
			else
				# Infinity if Element outside Cell border
				INFINITY
			end
		end
		
		minimize func, list
	end
	
	protected
	def minimize functional, list
		list.should! :be_a, ResultSet			
		rs = Browser::ResultSet.new @browser
		
		classified = list.to_set.classify{|pos| functional.call(pos)}.sort				
		classified.delete_if{|func, set| func >= INFINITY}
		return rs unless classified.size > 0
		
		rs.replace classified[0][1].to_a
		return rs
	end
	
	def minimize_distance metric, list, objects
		objects.should!(:be_a, ResultSet).size.should!(:>=, 1)
		
		func = lambda do |pos|
			# Geometric Average Distance between Elements
			average_distance = 0
			objects.each{|near_pos| average_distance += metric.call(pos, near_pos)**2}
			average_distance**0.5
		end
		
		minimize func, list
	end
end