class UpNotNil
	inherit Entity
	
	metadata do
		attribute :value, :object
		child :child
	end
end