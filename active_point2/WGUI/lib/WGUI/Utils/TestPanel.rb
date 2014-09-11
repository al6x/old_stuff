class TestPanel < WComponent
	children :children
	attr_accessor :children, :box

	def initialize;
		super
		@children = []
	end
end