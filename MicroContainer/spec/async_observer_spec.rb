require 'MicroContainer/require'
require 'spec'

Thread.abort_on_exception = true
module MicroContainer
	describe "MicroContainer" do										
		class TestObserver
			def on_msg
				TestObserver.counter += 1
			end
			
			@counter = 0
			class << self
				attr_accessor :counter
			end
		end
		
		before :each do			
			Scope.register AsyncObserver, :application do
				AsyncObserver.new
			end
			TestObserver.counter = 0
		end
		
		after :each do
			ScopeManager.clear_instances
#			Scope.unregister AsyncObserver			
#			Scope.unregister TestObserver
		end
		
		it "Should correct register listeners" do				
			lambda{Scope.add_observer :msg, TestObserver.new, :on_msg}.
			should raise_error(RuntimeError, /Can't be called outside of Session/)
			
			ScopeManager.activate_thread :sid do
				Scope.add_observer :msg, TestObserver.new, :on_msg
			end
		end
		
		it "Shouldn't add the same observer twice" do							
			obs = TestObserver.new			
			ScopeManager.activate_thread :sid1 do
				Scope.add_observer :msg, obs, :on_msg
				Scope.add_observer :msg2, obs, :on_msg
				Scope.add_observer :msg2, obs, :on_msg
			end								
			
			ao = Scope[AsyncObserver]
			messages = ao.instance_variable_get('@messages')
			sessions = ao.instance_variable_get('@sessions')
			messages[:msg].size.should == 1
			messages[:msg2].size.should == 1
			sessions[:sid1].registered.size.should == 2
		end	
		
		it "Should correct remove listeners" do							
			obs = TestObserver.new			
			ScopeManager.activate_thread :sid1 do
				Scope.add_observer :msg, obs, :on_msg
			end								
			ScopeManager.activate_thread :sid2 do
				Scope.add_observer :msg, obs, :on_msg
			end
			
			ao = Scope[AsyncObserver]
			messages = ao.instance_variable_get('@messages')
			sessions = ao.instance_variable_get('@sessions')
			
			messages.size.should == 1
			messages[:msg].size.should == 2
			sessions.size.should == 2
			
			lambda{
				Scope.delete_observer :msg, obs
			}.should raise_error(/Can't be called outside of Session/)
			
			ScopeManager.activate_thread :sid1 do
				Scope.delete_observer :msg, obs
			end								
			
			ao.instance_variable_get('@messages').size.should == 1
			ao.instance_variable_get('@sessions').size.should == 2
			ao.instance_variable_get('@sessions')[:sid1].registered.size.should == 0
			ao.instance_variable_get('@sessions')[:sid2].registered.size.should == 1
			
			lambda{
				Scope.delete_observers
			}.should raise_error(/Can't be called outside of Session/)
			
			ScopeManager.activate_thread :sid2 do
				Scope.delete_observers
			end
			
			ao.instance_variable_get('@sessions').size.should == 1
		end		
		
		it "Should correct remove observers" do
			obs = TestObserver.new			
			ScopeManager.activate_thread :sid1 do
				Scope.add_observer :msg, obs, :on_msg
			end						
			
			ScopeManager.activate_thread :sid2 do
				Scope.add_observer :msg, obs, :on_msg
			end
			
			lambda{Scope.delete_observers}.should raise_error(/Can't be called outside of Session/)
			
			ScopeManager.activate_thread :sid1 do
				Scope.delete_observers
			end								
			
			ao = Scope[AsyncObserver]
			ao.instance_variable_get('@messages').size.should == 1
			ao.instance_variable_get('@sessions').size.should == 1
		end
		
		it "Should correct remove sessions" do								
			ScopeManager.activate_thread :sid do
				Scope.add_observer :msg, TestObserver.new, :on_msg				
			end
			
			ao = Scope[AsyncObserver]
			ao.instance_variable_get('@messages').size.should == 1
			ao.instance_variable_get('@sessions').size.should == 1
			
			ScopeManager.activate_thread :sid do
				Scope.delete_observers
			end
			
			ao.instance_variable_get('@messages').size.should == 0
			ao.instance_variable_get('@sessions').size.should == 0
		end
		
		it "Should not allow to register Session Processer if there is no alive session" do
			lambda{
				ScopeManager.process_async_observers_for_session :sid
			}.should raise_error(InvalidSessionError, /There is no alive session/)
		end
		
		it "Should notify Observers from Application to Session Scopes" do
			obs = TestObserver.new						
			
			ScopeManager.activate_thread :sid do
				Scope.add_observer :msg, obs, :on_msg
			end										
			
			mock2 = mock("Message Processor Thread")
			mock2.should_receive(:done)
			Thread.new do
				ScopeManager.process_async_observers_for_session :sid
				mock2.done
			end
			
			Scope.notify_observers :msg
			Scope.notify_observers :another_msg
			sleep 0.2			
			TestObserver.counter.should == 1
		end
		
		it "Should notify Observers from Session to Session Scopes" do
			ScopeManager.activate_thread :sid1 do
				Scope.add_observer :msg, TestObserver.new, :on_msg
			end	
			
			ScopeManager.activate_thread(:sid1){}
			Thread.new do
				ScopeManager.process_async_observers_for_session :sid1
			end
			
			ScopeManager.activate_thread :sid2 do
				Scope.notify_observers :msg
			end	
			
			sleep 0.2
			
			TestObserver.counter.should == 1
		end
		
		it "Should notify Observers for Self" do
		ScopeManager.activate_thread :sid do
			Scope.add_observer :msg, TestObserver.new, :on_msg
		end	
		
		Thread.new do
			ScopeManager.process_async_observers_for_session :sid
		end
		
		ScopeManager.activate_thread :sid do
			Scope.notify_observers :msg
		end	
		
		sleep 0.2
		
		TestObserver.counter.should == 1
	end					
	
	def start_observer_thread			
		Thread.new do
			while true
				ScopeManager.process_async_observers_for_session :key, false
			end
		end
	end
	
	it "Concurrency Access" do
		class Counter
			extend Managed
			scope :session
			
			def initialize; @value = 0 end
			attr_reader :value
			def increase; @value += 1 end
		end
		
		class Container
			extend Injectable
			inject :counter => Counter
			
			def on_event
				counter.increase
			end
		end							
		
		container = Container.new
		MicroContainer::ScopeManager.activate_thread :key do								
			Scope.add_observer :msg, container, :on_event
		end			
		
		start_observer_thread
		
		threads = []
		5.times do
			threads << Thread.new do
				10.times do
					MicroContainer::ScopeManager.activate_thread :key do				
						container.counter.increase
					end
				end		
			end
			
			threads << Thread.new do
				10.times do
					Scope.notify_observers :msg
				end
			end
		end
		
		#			(threads + threads2).each{|t| t.join}
		sleep 0.5
		
		MicroContainer::ScopeManager.activate_thread :key do				
			container.counter.value.should == 100
		end
	end
end
end