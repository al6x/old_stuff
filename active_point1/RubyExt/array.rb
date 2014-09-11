class Array
	def sort_by_weight weight
		clone.sort_by_weight! weight.clone		
	end
	
	def sort_by_weight! weight
		size.times do |i|
			iteration = size - i - 1
			break if iteration < 0
			iteration.times do |j|
				if weight[j] > weight[j+1]
					buf = self[j]
					self[j] = self[j+1]
					self[j+1] = buf
					
					buf = weight[j]
					weight[j] = weight[j+1]
					weight[j+1] = buf
				end
			end
		end
		return self
	end
end