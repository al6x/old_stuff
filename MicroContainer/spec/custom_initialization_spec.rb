require 'MicroContainer/require'
require 'spec'

module MicroContainer
	describe "Custom Initialization" do		
		class AnInterface
			def test; "not implemented" end
		end
		
		class Impl1
			def test; 1 end
		end
		
		class Impl2
			def test; 2 end
		end                
		
		it "Custom initialization" do			
			Scope.register AnInterface, :session do
				Impl1.new
			end
			
			ScopeManager.activate_thread :key do
				Scope[AnInterface].test.should == 1
			end
			
			Scope.unregister AnInterface
			
			ScopeManager.activate_thread :key2 do
				lambda{Scope[AnInterface]}.should raise_error(/Name is not Managed/)
			end
		end
	end
end
