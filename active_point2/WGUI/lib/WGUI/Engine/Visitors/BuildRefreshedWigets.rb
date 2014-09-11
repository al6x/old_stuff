class BuildRefreshedWigets
	if $debug
		def accept wiget			
			@processed ||= Set.new
			@processed.should_not! :include?, wiget.object_id
			@processed << wiget.object_id
			
			wiget.respond_to :build if wiget.refreshed?
			return true
		end
	else
		def accept wiget
			wiget.respond_to :build if wiget.refreshed?
			return true
		end
	end
end