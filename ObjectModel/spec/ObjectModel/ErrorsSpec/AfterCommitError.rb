class AfterCommitError
	inherit Entity
	
	metadata do
		after :commit do
			name.should_not! :be_nil
		end
	end
end