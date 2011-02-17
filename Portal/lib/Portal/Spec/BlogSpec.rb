require 'ActivePoint/Spec/require'
require 'RubyExt/require'
require 'UIDRiver/require'

include UIDRiver::BrowserHelper

describe "Blog" do		
	def go url
		UIDRiver::BrowserHelper.go "localhost:8080/ui/Portal/Site/Blog#{url}"
	end
	
	it "" do
		go ""
		click "[New Post]"
		wait_for{have_text("Edit Post")}
		type :text => "Title 1", :from_right_of => "Title:"
		type :text => "Details 1", :from_right_of => "Details:"
		type :text => "Text 1", :from_bottom_of => "Details:"
		click "Ok"
		
		should! :have_text, "Title 1"
		should! :have_text, "Details 1"
		should! :have_text, "Text 1"
	end
	
	after :all do
#		close
	end
end