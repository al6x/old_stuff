class Border < WComponent
	include Container
	
	#	attr_accessor :positions
	
	attr_accessor :center, :left, :right, :top, :bottom
	children :center, :left, :right, :top, :bottom
	
	def add position, wiget		
		position.should! :be_in, [:center, :left, :right, :top, :bottom]
		wiget.should! :be_a, [Array, WGUI::Wiget]
		
		send position.to_writer, wiget
	end
end