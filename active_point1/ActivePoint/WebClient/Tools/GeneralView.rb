class GeneralView < WComponent
	inherit UView
	
	def build
		super
		Scope.add_observer object.om_id, self, :refresh
	end
end