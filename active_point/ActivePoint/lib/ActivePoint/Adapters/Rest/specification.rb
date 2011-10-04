module ActivePoint
	module Adapters
		module Rest
			
			module Specification
				module Client
					def translate name, password, uri, method, *args
						data = args.to_json						
						
						uri = base_uri + "/" + uri
						result_str = RestClient.post uri, :name => name, :password => password, 
						:method => method.to_s, :data => data
						
						result = JSON.parse result_str
						if result.include? "error"
							e = RuntimeError.new result["error"]
							e.set_backtrace result["backtrace"]
							raise e
						end
						raise %{Responce should include "result"!} unless result.include? "result"
						return result["result"]
					end
				end
				
				module Service
					def translate &b
						begin						
							name, password, method = params[:name], params[:password], params[:method]			
							if method and !method.empty?
								method = method.to_sym
							end
							
							args = JSON.parse(params[:data])
							user = Scope[:services][:security].user_for name, password
							
							result = b.call user, method, *args
							
							{"result" => result}.to_json
						rescue Exception => e
							{"error" => e.message, "backtrace" => e.backtrace}.to_json
						end						
					end
				end		
			end
			
		end
	end
end