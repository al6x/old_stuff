class DSL
	def initialize klass, &block
		@klass = klass
		@meta = Metadata.new klass
		@klass.self_meta = @meta
		self.instance_eval &block
		
		full_meta = klass.meta
		Metadata["metadata_checks.rb"].each{|check| check.call klass, full_meta}
	end
end