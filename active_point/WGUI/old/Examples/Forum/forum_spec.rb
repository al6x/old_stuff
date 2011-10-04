require 'WGUI/scripts/web_spec'
require 'wgui/spec/examples/forum/forum'

describe "Basic forum" do
	before :all do 
		stop_webserver
		Runner.start Forum::Forum
    end
	after :all do
		Runner.stop		
		close
    end
	
	it 'should display topics' do
		go 'localhost/forum/general_forum'
		wait_for.should have_text('I like Terminator')
		
		go 'localhost/bad_url'
		wait_for{uri =~ /localhost\/forum\/general_forum/}
		wait_for.should have_text('I like Terminator')
    end
	
	it 'should display topics' do
		go 'localhost/forum/general_forum'
		
		go 'localhost/bad_url'
		wait_for{uri =~ /localhost\/forum\/general_forum/}
		wait_for.should have_text('I like Terminator')
    end
	
	it 'should add new topic' do
		go 'localhost/forum'
		click 'Add'		
		type :text => 'new topic', :from_bottom_of => 'Name'; 
		type :text => 'topic text', :from_bottom_of => 'Text'
		click 'Ok'
		wait_for.should have_the(:link => 'new topic'); 
		click 'new topic'
		wait_for.should have_text('topic text')
    end
	
	it 'should display topic' do
		go 'localhost/forum/general_forum'
		click 'Ninja'
		wait_for.should have_text('Im found new Ninja school')
		uri.should include("/forum/general_forum/topic/Ninja")
    end
	
	it 'should serve URLs' do
		go 'localhost/forum/general_forum/topic/I like Terminator'
		wait_for.should have_text(/I watch movie Terminator/)
		uri.should include("/forum/general_forum/topic/I like Terminator")
    end
	
	it "invalid url's should changes to valid" do
		go "localhost/forum/general_forum/topic/bad_topic_name"
		
		wait_for{uri =~ /localhost\/forum\/general_forum/}
		uri.should_not include("topic/bad_topic_name")        
		should have_the(:link => 'I like Terminator')
    end
	
	it "should autochange URI after changing Topic Name" do
		go "localhost/forum/general_forum/topic/Ninja"
		click :button => 'Edit', :from_right_of => 'Ninja'
		type :text => 'Ninja2', :from_bottom_of => 'Name'
		click 'Ok'
		wait_for.should have_text('Ninja2')
		uri.should include("/forum/general_forum/topic/Ninja2")
    end
	
	it "should delete topics" do
		go "localhost/forum/general_forum/topic/A flight to the Moon"
		click :button => 'Delete', :from_right_of => 'A flight to the Moon'
		wait_for {uri.include?('localhost/forum/general_forum')}
		should_not have_the(:link => "A flight to the Moon")
    end
	
	it "should add edit and delete comment" do
		# add
		go "localhost/forum/general_forum/topic/I like Terminator"
		click "Comment"
		type 'Comment' => 'new_comment'
		click "Ok"
		wait_for.should have_text('new_comment')
		
		#edit
		click :button => 'Edit', :from_right_of => 'new_comment'
		type 'Comment' => 'new_comment2'
		click 'Ok'
		wait_for.should have_text('new_comment2')
		
		#delete
		click :button => 'Delete', :from_right_of => "new_comment2"
		wait_for{!has_text?("new_comment")}
    end
end