class RaiseWithoutSelf
	def test
		raise_without_self "Error"
	end
	
	def test2
		raise_without_self "Error", [RaiseWithoutSelf, Raise2]
	end
end