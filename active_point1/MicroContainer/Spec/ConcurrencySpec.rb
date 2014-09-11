require 'MicroContainer/require'
require 'spec'

module MicroContainer
	Thread.abort_on_exception = true
	describe "MicroContainer Concurrency" do		
		class Counter
			extend Managed
			scope :session
			
			def initialize; @value = 0 end
			attr_reader :value
			def increase; @value += 1 end
		end
		
		class Container
			extend Managed
			include CMessaging
			scope :session
			inject :counter => Counter
			
			def initialize
				listen_to :msg, :on_msg
			end
			
			def on_msg
				counter.increase
			end
		end			
		
		class MsgSender
			include CMessaging
		end
		
		it "Concurrency Access" do
			MicroContainer::ScopeManager.activate_thread :key do				
				Scope[Container].counter.value.should == 0
			end
			
			t1 = Thread.new do
				100.times do
					MicroContainer::ScopeManager.activate_thread :key do				
						Scope[Container].counter.increase
					end
				end
			end
			
			t2 = Thread.new do
				100.times do
					MicroContainer::ScopeManager.activate_thread :key do				
						Scope[Container].counter.increase
					end
				end		
			end
			
			t1.join; t2.join
			MicroContainer::ScopeManager.activate_thread :key do				
				Scope[Container].counter.value.should == 200
			end
		end
		
		it "Concurrency Access for_ :application Scope" do
			Scope.register(:counter, :application){0}
			MicroContainer::ScopeManager.activate_thread :key do				
				Scope[:counter] = 0
			end
			
			threads = []
			20.times do 
				threads << Thread.new do
					MicroContainer::ScopeManager.activate_thread :key do
						1000.times do									
							Scope[:counter] += 1
						end
					end
				end
			end 			
			threads.each{|t| t.join}
			
			MicroContainer::ScopeManager.activate_thread :key do				
				Scope[:counter].should == 20000
			end
		end
		
		it "ObserverThread, should delete old Thread if a new one will register" do			
			MicroContainer::ScopeManager.activate_thread :sid do				
			end
			
			ot1 = Thread.new do
				MicroContainer::ScopeManager.process_async_observers_for_session :sid
			end
			sleep 0.1
			
			ot2 = Thread.new do	
				MicroContainer::ScopeManager.process_async_observers_for_session :sid
			end
			sleep 0.1
			ot1.should_not be_alive
			ot2.should be_alive			
		end
		
		it "activate_thread_without_synchronization" do
			raise "Not implemented!"
		end
	end
end







