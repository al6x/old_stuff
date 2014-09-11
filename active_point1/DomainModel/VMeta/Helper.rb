class Helper
	attr_accessor :vmeta, :klass
	def initialize klass, &block
		@klass = klass
		@vmeta = VMeta.new klass
		block.call self
	end
end