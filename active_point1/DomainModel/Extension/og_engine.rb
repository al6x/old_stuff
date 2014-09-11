::OGDomain::Engine
class ::OGDomain::Engine
	def [] path
		path = Path.new path if path.is_a? String
		entity = root
		return entity if entity.name != path.first or path.size <= 1 
		path.next.each do |part|
			found = false
			entity.each(:children) do |child|
				if child.name == part
					entity = child
					found = true
					break
				end				
			end
			break unless found            
		end
		return entity
	end
	
	def path_to entity
		path, current = Path.new(entity.name), entity
		while current = current.parent
			path = Path.new(current.name) + path
		end 
		path
	end
end