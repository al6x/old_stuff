require 'MicroContainer/require'
require 'spec'

Thread.abort_on_exception = true
module MicroContainer
	describe "MicroContainer" do		
		class AppMessage
			include CMessaging
			attr_accessor :listener
			
			def on_msg
				listener.on_msg
			end
		end
		
		class SessionMessage
			include CMessaging
			attr_accessor :listener
			
			def on_msg
				listener.on_msg
			end
		end
		
		before :each do			
			ScopeManager.clear
			Scope.register(AppMessage, :application){AppMessage.new}
			Scope.register(SessionMessage, :session){SessionMessage.new}
			Scope.register(MQ::MessageQueue, :application){MQ::MessageQueue.new}
		end
		
		it "Should correct register listeners" do				
			Scope[MQ::MessageQueue].listen_to AppMessage, :msg, :on_msg
			
			lambda{Scope[MQ::MessageQueue].listen_to SessionMessage, :msg, :on_msg}.
			should raise_error(RuntimeError, /cannot be registered outside of its Session/)
			
			ScopeManager.activate_thread :sid do
				Scope[MQ::MessageQueue].listen_to SessionMessage, :msg, :on_msg
			end
		end
		
		it "Should correct remove listeners" do				
			mq = Scope[MQ::MessageQueue]
			mq.listen_to AppMessage, :msg, :on_msg		
			ScopeManager.activate_thread :sid do
				mq.listen_to SessionMessage, :msg2, :on_msg
			end
			mq.instance_variable_get('@messages').size.should == 2
			mq.instance_variable_get('@sessions').size.should == 1
			
			mq.detach_from AppMessage, :msg
			mq.detach_from SessionMessage, :msg2
			
			mq.instance_variable_get('@messages').size.should == 0
			mq.instance_variable_get('@sessions').size.should == 1
			mq.instance_variable_get('@sessions')[:sid].registered.size.should == 0
			
			mq.delete_session :sid
			mq.instance_variable_get('@sessions').size.should == 0			
		end		
		
		it "Should correct remove sessions" do				
			mq = Scope[MQ::MessageQueue]
			mq.listen_to AppMessage, :msg, :on_msg		
			ScopeManager.activate_thread :sid do
				mq.listen_to SessionMessage, :msg2, :on_msg
			end
			mq.instance_variable_get('@messages').size.should == 2
			mq.instance_variable_get('@sessions').size.should == 1
			
			mq.delete_session :sid
			
			mq.instance_variable_get('@messages').size.should == 1
			mq.instance_variable_get('@sessions').size.should == 0
		end
		
		it "Should not allow to register Session Processer if there is no alive session" do
			lambda{ScopeManager.process_messages_for_session :sid}.
			should raise_error(InvalidSessionError, /There is no alive session/)
		end
		
		it "Should send messages from App to Session" do
			mock = mock("Message listener")
			mock.should_receive(:on_msg)
			
			ScopeManager.activate_thread :sid do
				Scope[SessionMessage].listen_to :msg, :on_msg
				Scope[SessionMessage].listener = mock
			end										
			
			mock2 = mock("Message Processor Thread")
			mock2.should_receive(:done)
			Thread.new do
				ScopeManager.process_messages_for_session :sid
				mock2.done
			end
			
			Scope[AppMessage].send_message :msg
			Scope[AppMessage].send_message :another_msg
			sleep 0.5			
		end
		
		it "Should send messages from Session to App" do
			mock = mock("Message listener")
			mock.should_receive(:on_msg)
			Scope[AppMessage].listen_to :msg, :on_msg
			Scope[AppMessage].listener = mock
			
			ScopeManager.activate_thread :sid do
				Scope[SessionMessage].send_message :msg
				Scope[SessionMessage].send_message :another_msg
			end
			sleep 0.5
		end						
		
		def start_observer_thread count
			threads = []
			t = Thread.new do
				while true
					ScopeManager.process_messages_for_session :key, false
				end
			end
			threads << t
			return threads
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
				extend Managed
				include CMessaging
				scope :session
				inject :counter => Counter
				
				def on_event
					counter.increase
				end
			end
			
			class TestCMessaging
				include CMessaging
			end
			
			mp = TestCMessaging.new									
			
			MicroContainer::ScopeManager.activate_thread :key do				
				container = Scope[Container]
				container.counter.value.should == 0				
				container.listen_to :msg, :on_event
			end			
			
			threads2 = start_observer_thread 50
			
			threads = []
			5.times do
				threads << Thread.new do
					10.times do
						MicroContainer::ScopeManager.activate_thread :key do				
							Scope[Container].counter.increase
						end
					end		
				end
				
				threads << Thread.new do
					10.times do
						mp.send_message :msg
					end
				end
			end
			
			#			(threads + threads2).each{|t| t.join}
			sleep 0.5
			
			MicroContainer::ScopeManager.activate_thread :key do				
				Scope[Container].counter.value.should == 100
			end
		end
	end
end