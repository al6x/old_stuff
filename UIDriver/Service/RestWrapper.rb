class RestWrapper < Sinatra::Base	
	post "/service/:method_name" do 		
		SeleniumService.log.info params.inspect
		begin
			return rcall SeleniumService.instance, params[:method_name], params
		rescue Exception => e
			SeleniumService.log.error e
			return e.message
		end
	end
	
	post "/browser/:browser_id/:method_name" do				
		BrowserAdapter.log.info params.inspect
		begin
			browser = SeleniumService.instance.get_browser params[:browser_id].should_not!(:be_nil)
			browser.touch!
			return rcall browser, params[:method_name], params
		rescue Exception => e
			BrowserAdapter.log.error e
			return e.message
		end
	end
	
	get "/blank_page" do
%{\
<html>
	<head>
	</head>
  <body>        
    <div>
    </div>
  </body>
</html>}		
	end
	
	protected
	def rcall target, method, args
		args.should! :be_a, Hash
#		args.keys.every.should! :be_a, Symbol
		args.values.every.should! :be_a, String
		
		result = target.send :"ws_#{method}", args
		result.should! :be_a, String
		
		headers "method_call_status" => "success"
		
		return result
	end
end