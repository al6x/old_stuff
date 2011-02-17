require 'MicroContainer/require'
require 'spec'

module MicroContainer
	describe "MicroContainer" do		
		class CustomScope
			extend Managed
			scope :custom			
			
			attr_accessor :value
		end
		
		class CustomScopeScope
			extend Managed
			scope :application
			
			def start; end
			scope_begin :start, :custom
			
			def stop; end
			scope_end :stop, :custom
		end
		
		it "Should raise error if not started" do
			lambda{Scope[CustomScope]}.should raise_error(/nil:NilClass/)
		end
		
		it "General usage case" do			
			manager = Scope[CustomScopeScope]
			c = nil
			MicroContainer::ScopeManager.activate_thread :key do
				manager.start
				c = Scope[CustomScope]
				c.should_not be_nil
			end
			
			MicroContainer::ScopeManager.activate_thread :key do 
				c.equal?(Scope[CustomScope]).should be_true
				manager.stop
			end
			
			MicroContainer::ScopeManager.activate_thread :key do
				lambda{Scope[CustomScope]}.should raise_error(/hasn't been started/)
				manager.start
				c.equal?(Scope[CustomScope]).should be_false
				manager.stop
			end
		end
		
		it "active?" do			      
			MicroContainer::ScopeManager.activate_thread :key do
				Scope.active?(:custom).should be_false
				Scope.begin :custom
				Scope.active?(:custom).should be_true
				Scope.end :custom
				Scope.active?(:custom).should be_false
			end
		end
		
		it "Should clear not closed scope when reopen" do
			manager = Scope[CustomScopeScope]
			c = nil
			MicroContainer::ScopeManager.activate_thread :key do
				manager.start
				c = Scope[CustomScope]
			end
			
			MicroContainer::ScopeManager.activate_thread :key do
				manager.start
				c.equal?(Scope[CustomScope]).should be_false
				manager.stop
			end
		end
		
		it "Should set custom values" do
			manager = Scope[CustomScopeScope]
			
			MicroContainer::ScopeManager.activate_thread :key do
				manager.start
				Scope[CustomScope] = 'new value'
				Scope[CustomScope].should == 'new value'
				manager.stop
			end
		end
		
		it "Continuation, general usage" do            			
			MicroContainer::ScopeManager.activate_thread :session_id do
				Scope.begin :custom                
				Scope[CustomScope].value = 'value'
				Scope[CustomScope].value.should == 'value'
				
				Scope.continuation_begin :custom
				Scope[CustomScope].value.should == nil
				Scope[CustomScope].value = 'value2'
				Scope[CustomScope].value.should == 'value2'
				Scope.continuation_end :custom                
				
				Scope[CustomScope].value.should == 'value'                
				Scope.end :custom
			end
		end
		
		it "Continuation, if scope closes it should also close all continuations" do            			
			MicroContainer::ScopeManager.activate_thread :session_id do
				Scope.begin :custom                
				Scope[CustomScope].value = 'value'                
				
				Scope.continuation_begin :custom                
				Scope[CustomScope].value = 'value2'                           
				Scope.end :custom
				
				lambda{Scope[CustomScope]}.should raise_error(/hasn't been started/)
			end
		end
		
		it "Before & After custom Scope" do
			mock = mock("Before & After")                  
			
			Scope.before(:custom3){mock.before}      
			Scope.after(:custom3){mock.after}
			
			MicroContainer::ScopeManager.activate_thread :session_id do
				mock.should_receive(:before)      
				Scope.begin :custom3                                                  
				
				mock.should_receive(:after)
				Scope.end :custom3     
			end
		end
		
		it "Before & After custom Scope, shouldn't be called in Continuations" do
			mock = mock("Before & After")                  
			
			Scope.before(:custom2){mock.before}      
			Scope.after(:custom2){mock.after}
			
			MicroContainer::ScopeManager.activate_thread :session_id do
				mock.should_receive(:before)
				Scope.begin :custom2                                 
				Scope.continuation_begin :custom2                
				
				mock.should_receive(:after)
				Scope.end :custom2     
			end
			
			Scope.after(:custom2){}
			Scope.before(:custom2){}
		end
		
		it "Save and Restore Scope, general usage" do            			
			MicroContainer::ScopeManager.activate_thread :session_id do
				Scope.begin :custom                
				Scope[CustomScope].value = 'value'
				Scope[CustomScope].value.should == 'value'
				
				save = Scope.custom_scope_get :custom
				Scope.begin :custom       
				
				Scope[CustomScope].value.should == nil
				
				Scope.custom_scope_set :custom, save
				
				Scope[CustomScope].value.should == 'value'
				
				Scope.end :custom
			end            
		end
		
		it "Scope Groups (Defines Group and forwards all calls to Scope for_each Participant)" do
			Scope.register :object, :object
			Scope.register :view, :view
			
			Scope.group(:object_group) << :object
			Scope.group(:object_group) << :view
			
			MicroContainer::ScopeManager.activate_thread :session_id do
				lambda{Scope[:object]}.should raise_error(/hasn't been started/)
				Scope.group(:object_group).begin
				Scope[:object]
			end
		end
	end
end
