require "ActivePoint/Adapters/Rest/client"
require 'spec'

module ActivePoint
	module RestAdapterSpec
		REST_URI = "localhost:8080/rest"
		
		describe "Rest Adapter" do
			it "eval should be Secure" do
				client = Adapters::Rest::Client.new REST_URI
				lambda{
					client.eval("")
				}.should raise_error(/User with such Name and Password not found!/)
			end
			
			it "eval" do
				client = Adapters::Rest::Client.new REST_URI, "admin", ""
				client.eval("1 + 2").should == 3
			end
			
			it "RestController should be Secure" do
				client = Adapters::Rest::Client.new REST_URI				
				lambda{
					client["Core/Development"].eval 
				}.should raise_error(/User with such Name and Password not found!/)
			end
			
			it "RestController" do
				client = Adapters::Rest::Client.new REST_URI, "admin", ""
				client["Core/Development"].eval("1 + 2").should == 3
			end
		end		
	end	
end
