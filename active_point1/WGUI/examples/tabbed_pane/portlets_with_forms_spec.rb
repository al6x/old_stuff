require 'WGUI/scripts/web_spec'
require 'wgui/spec/examples/tabbed_pane/portlets_with_forms'

describe "Portlets with forms" do
  before :all do 
	  stop_webserver
	  Runner.start TabbedPane::PortletsWithForms
  end
  after :all do 
	  Runner.stop
	  close
  end
	
  it 'Forms should correct works with portlets' do
    go 'localhost/tab/one?one=tab/one'
    type 'Set me ...' => 'v1'
    click 'Set'
    wait_for.should have_text('v1')
  end
end