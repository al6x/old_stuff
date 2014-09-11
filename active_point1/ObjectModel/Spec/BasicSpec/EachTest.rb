class EachTest
	inherit Entity
	
	metadata do
		attribute :a1, :string, :initialize => "a1"
		attribute :a2, :string, :initialize => "a2"
		
		child :child
		child :children, :bag
		
		reference :reference
		reference :references, :bag
	end
end