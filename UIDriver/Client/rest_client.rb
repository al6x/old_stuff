class RestClient::Resource
	[:type, :select, :eval].each{|m| undef_method m}
	
	def method_missing m, args = {}		
		args.should! :be_a, Hash
		args.keys.every.should! :be_a, Symbol
		args.values.every.should! :be_a, String
		
		responce = self[m].post args
		unless responce.headers[:method_call_status] == "success"
			raise RuntimeError, "RemoteError: #{responce}", caller 
		end
		return responce
	end
end