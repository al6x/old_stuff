class BagType
	class << self
		def initial_value m, e
			bag = calculate_class(m).new e, m.name, e.om_repository
			e.instance_variable_set m.ivname, bag
		end
		
		def initialize_copy m, e, c
			bag = e.instance_variable_get m.ivname
			bag_copy = AnEntity::BagCopy.new bag._array
			c[m.ivname] = bag_copy
		end
		
		def initialize_storage db			
			db.create_table :bags do
				column :om_id, :text
				column :name, :text 
				column :reference_id, :text						
			end
		end
		
		def print_storage db, name
			return unless name == nil or name == :bags
			puts "\nBags:"
			db[:bags].print
		end
		
		def load m, e, storage		
			rows = storage[:bags].filter :om_id => e.om_id, :name => m.name.to_s
			bag = calculate_class(m).new e, m.name, e.om_repository
			rows.each do |row|
				value = AnEntity::EntityType.load_id row[:reference_id]				
				bag._array << value
			end
			e.instance_variable_set m.ivname, bag
		end 
		
		def write_back c, e, m				
			bag_copy = c[m.ivname]
			bag = e.instance_variable_get m.ivname
			bag._array.replace bag_copy._array # TODO reimplement more efficiently
		end
		
		def persist c, om_id, m, storage		
			# TODO reimplement more efficiently
			sname = m.name.to_s
			storage[:bags].filter(:om_id => om_id, :name => sname).delete
			c[m.ivname]._array.each do |ref_id|		
				ref_id.should_not! :be_nil
				storage[:bags].insert(
															:om_id => om_id, 
															:name => sname,
															:reference_id => AnEntity::EntityType.dump_id(ref_id)
				)
			end								
		end
		
		def delete e, m, storage		
			storage[:bags].filter(:om_id => e.om_id).delete
		end
		
		def delete_all_children e, m
			bag = e.send m.name
			bag.every.delete
		end
		
		def delete_all_references_to referrer, e, m			
			bag = referrer.send m.name
			bag.delete e
		end
		
		def delete_from_parent e, parent, m
			bag = parent.send m.name
			bag.delete e
		end
		
		def each e, m, &b
			bag = e.send m.name
			bag.each &b
		end
		
		protected
		def calculate_class m
			if m.is_a? Metadata::Child
				AnEntity::ChildrenBag
			elsif m.is_a? Metadata::Reference
				AnEntity::ReferencesBag
			else
				should! :be_never_called
			end
		end
	end
end