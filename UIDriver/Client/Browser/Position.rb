class Position
	attr_reader :left, :top, :width, :height, :xpath
	
	def initialize xpath, array
		array.size.should! :==, 4
		@xpath = xpath
		@left, @top, @width, @height = array		
	end
	
	def to_a
		[@left, @top, @width, @height]
	end
	
	def right
		@left + @width		
	end
	
	def bottom
		@top + @height
	end
	
	def center_x
		@left + @width/2
	end
	
	def center_y
		@top + @height/2
	end
	
	def inside_of? pos				
		(left >= pos.left) and (top >= pos.top) and \
		(right <= pos.right) and (bottom <= pos.bottom)
	end		
	
	def intersect? pos
		intersect_x?(pos) and intersect_y?(pos)		
	end
	
	def intersect_x? pos
		[left, right].any?{|x| x >= pos.left and x <= pos.right} or
		[pos.left, pos.right].any?{|x| x >= left and x <= right}
	end
	
	def intersect_y? pos
		[top, bottom].any?{|y| y >= pos.top and y <= pos.bottom} or
		[pos.top, pos.bottom].any?{|y| y >= top and y <= bottom}
	end	
	
	def distance pos
		((center_x - pos.center_x)**2 + (center_y - pos.center_y)**2)**0.5
	end
	
	def == pos
		return unless pos.is_a?(Position)
		@xpath == pos.xpath
	end
	
	def hash
		@xpath.hash
	end
	
	def eql? pos
		@xpath.eql? pos.xpath
	end
	
	def to_s
		"#{@xpath} #{to_a.inspect}"
	end
	alias :inspect :to_s
end