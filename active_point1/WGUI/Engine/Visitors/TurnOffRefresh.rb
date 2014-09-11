class TurnOffRefresh
	def self.accept wiget
		wiget.refresh = false if wiget.refreshed?
	end
end