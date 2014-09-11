require 'howt/browser_helper'
require 'spec'

include HOWT::BrowserHelper
module HOWT	
	module BrowserUsageSpec				
		describe 'General specification' do			
			after :all do close end					
			
			it "start/stop" do
				go 'localhost:7000/has_text'
				wait_for.should have_text('Text')
				close
				
				go 'localhost:7000/has_text'
				wait_for.should have_text('Text')
				close
            end
			
			it "complex start/stop" do
				open :browser
				go 'localhost:7000/has_text'
				wait_for.should have_text('Text')
				
				close
				wait_for.should have_text('Text')
				close :browser
            end
		end
	end
end