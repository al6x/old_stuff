::OGDomain::Entity
module ::OGDomain::Entity
	build_dmeta do |m|
		m.attribute :name, :string, "Name"
		m.mandatory :name
	end
	
	module ClassMethods
		attr_accessor :self_vmeta
		
		def build_vmeta &b;		
			h = DomainModel::VMeta::Helper.new(self, &b)
			self.self_vmeta = h.vmeta
		end
		
		def vmeta
			parent = ancestors.find{|a| a.respond_to(:vmeta) and a != self}
			result = if parent
				self_vmeta.inherit parent.vmeta
			else
				self_vmeta
			end
			return result
		end
		
		def storage; Scope[:storage] end
	end	
	
	extend ClassMethods
	
	build_dmeta do |m|
		m.attribute :name, :string, "Name"
		m.mandatory :name
	end
	
	build_vmeta do |m|		
	end
	
	def path
		og_engine.path_to self	
	end
end