class EntityCopy
	attr_accessor :om_version, :parent, :back_references, :entity_id, :om_id
	
	def initialize
		@hash = {}
		@new, @moved, @deleted, @updated = false, false, false, false
	end
	
	def [] ivname
		ivname.should! :=~, /^@.+/ if $debug
		@hash[ivname]
	end
	
	def []= ivname, value
		ivname.should! :=~, /^@.+/ if $debug
		@hash[ivname] = value
	end
	
	def new?; @new end
	def new!; @new = true end
		
	def updated?; @updated end
	def updated!; @updated = true end
		
	def deleted?; @deleted end
	def deleted!; @deleted = true end
		
	def moved?; @moved end
	def moved!; @moved = true end		
	
	def to_s
		"#<#EntityCopy: #{entity_id}>"
	end
	
	def inspect
		to_s
	end
end