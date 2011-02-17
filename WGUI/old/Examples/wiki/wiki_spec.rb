require 'WGUI/scripts/web_spec'
require 'wgui/spec/examples/wiki/wiki'

describe 'Wiki' do
	before :all do 
		stop_webserver
		Runner.start Wiki
    end
	after :all do 		
		Runner.stop
    end
	
	it 'should display main page and correct redirect' do
		go 'localhost'
		wait_for.should have_text('Home')
    end
	
	it 'should correct restore state by link' do
		go 'localhost/wiki/Page%202'
		wait_for.should have_text('Page 2')
    end
	
	it 'navigation should works' do
		go 'localhost'
		click('Page 1')
		wait_for.should have_text('Page 1')
		click('Page 2')
		wait_for.should have_text('Page 2')		
    end
	
	it 'should edit pages' do
		go 'localhost/wiki/Page%201'
		click('Edit')
		wait_for.should have_text('Name')
		should have_text('Text')
		click('Cancel')
		wait_for.should have_text('Page 1')
		
		click('Edit')
		type 'Text' => 'new_value'
		click('Ok')
		wait_for.should have_text('new_value')
    end
end