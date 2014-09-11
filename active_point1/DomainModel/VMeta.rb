class VMeta 	
	@definition = {}
	class << self	
		attr_accessor :definition
	end
	
	attr_accessor :klass
	
	def initialize klass
		super()
		@klass = klass
		VMeta.definition.each do |name, defn|
			send name.to_writer, defn.initial_value
		end
	end															
	
	def inherit parent
		unless parent
			where?
			raise "parent is nil" 
		end
		
		new = VMeta.new klass
		VMeta.definition.each do |name, defn|
			pmeta = parent.send name
			cmeta = self.send name
			new.send name.to_writer, defn.inherit(pmeta, cmeta)
		end
		return new					
	end
end

VMeta::Helper # Require before we alter it.

require 'DomainModel/Actions/vmeta'