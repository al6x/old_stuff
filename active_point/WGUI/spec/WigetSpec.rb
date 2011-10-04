require 'WGUI/web_spec'

module WGUI	
	module Spec
		module WigetSpec
			register_wiget "Should use parent's template if nod fined it's own (from error)" do				
				WChild.new			
			end

#			start_webserver; join_webserver;
			describe "Wiget" do
				it "Should use parent's template if nod fined it's own (from error)" do
					go "localhost:8080/ui?t=Should use parent's template if nod fined it's own (from error)"
					# Label
					wait_for.should have_text("WParent's Template")
				end			
			end
		end
	end
end