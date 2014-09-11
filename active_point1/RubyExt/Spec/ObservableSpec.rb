require 'RubyExt/require_base'
require 'spec'

module RubyExt
	module ObservableSpec
		describe "Observable" do
			class AnObservable
				include Observable
			end
			
			it "Method without Parameters" do
				mock = mock("Observer")
				obs = AnObservable.new
				obs.add_observer mock
				mock.should_receive(:update).with(2)
				obs.notify_observers :update, 2			
			end
			
#			it "Method without Parameters" do
#				mock = mock("Observer")
#				obs = AnObservable.new
#				obs.add_observer(mock, :method => :custom_update, :filter => lambda{|o| o == 2})
#				mock.should_receive(:custom_update).with(2)
#				obs.notify_observers 2
#				obs.notify_observers 4
#			end
#			
#			it "With Block" do
#				mock = mock("Observer")
#				mock.should_receive(:got)
#				obs = AnObservable.new
#				obs.add_observer{mock.got}
#				obs.notify_observers
#			end
#			
#			it "With Block and Filter" do
#				mock = mock("Observer")
#				obs = AnObservable.new
#				obs.add_observer(:filter => lambda{|o| o == 2}){|o| mock.got o}
#				mock.should_receive(:got).with(2)
#				obs.notify_observers 2
#				obs.notify_observers 4									
#			end
		end
	end
end