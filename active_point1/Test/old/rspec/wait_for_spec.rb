require 'spec'
require 'howt/rspec/wait_for'

module Spec	
	module WaitForSpec				
		describe 'Wait for condition' do			
			before :all do 
				Spec::WaitFor.timeout = 3
            end
			
			class Delayed
				attr_accessor :text
				def has_text?; text end
            end
			
			it "wait_for_should" do
				delayed = Delayed.new
				delayed.text = false
				Thread.new{sleep 2; delayed.text = true}
				
				delayed.should_not have_text
				delayed.wait_for_should have_text
            end
			
			it "wait_for_should_not" do
				delayed = Delayed.new
				delayed.text = true
				Thread.new{sleep 2; delayed.text = false}
				
				delayed.should have_text
				delayed.wait_for_should_not have_text
            end
		end
	end
end