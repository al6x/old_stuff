module ::ObjectModel
	class Repository
		def transaction_begin
			Scope.begin :transaction
		end
	end
end