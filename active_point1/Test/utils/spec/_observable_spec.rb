require 'utils/observable'
require 'spec'

module Utils
	describe "Observable" do				
		class AnObservable
			include Observable
        end
				
		it do
			mock = mock("Observer")						
			obs = AnObservable.new			
			obs.add_observer mock
			mock.should_receive(:update).with(obs)
			obs.notify_observers			
		end
		
		it do
			mock = mock("Observer")
			obs = AnObservable.new			
			obs.add_observer(mock, :custom_update){|o| o == 2}
			mock.should_receive(:custom_update).with(2)
			obs.notify_observers 2
        end
		
		it do
			mock = mock("Observer")
			obs = AnObservable.new			
			obs.add_observer(mock){|o| o == 2}
			mock.should_receive(:update).with(2)
			obs.notify_observers 2
        end
		
		it "Should't notify observer if block evals to false" do
			mock = mock("Observer")
			obs = AnObservable.new			
			obs.add_observer(mock){false}			
			obs.notify_observers
        end
		
		it "Should be able use block as Observer" do 
			mock = mock("Observer")
			mock.should_receive(:got)
			obs = AnObservable.new			
			obs.add_observer{mock.got}			
			obs.notify_observers
        end
	end
end