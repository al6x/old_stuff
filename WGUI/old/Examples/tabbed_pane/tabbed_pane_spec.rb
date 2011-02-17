require 'WGUI/scripts/web_spec'
require 'wgui/spec/examples/tabbed_pane/tabbed_pane'

describe "URL's in complex components" do
  before :all do 
	  stop_webserver
	  Runner.start TabbedPane::RootComponent
  end
  after :all do 
	  Runner.stop
	  close
  end
	
  it 'should correct restore state by URL' do
    go 'localhost/tab/one?one=tab/one'
    wait_for.should have_text('one one ...')
    uri.should include("localhost/tab/one?one=tab/one")
  end
end