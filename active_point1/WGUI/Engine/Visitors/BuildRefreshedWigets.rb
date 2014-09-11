class BuildRefreshedWigets
	def accept wiget
		wiget.respond_to :build if wiget.refreshed?
	end
end