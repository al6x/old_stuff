require 'spec'
require 'WGUI/require'

module WGUI
	module StateSpec	  
		class PortletStub < WComponent
			include WPortlet        
		end
	
		describe "URI to State conversions" do
			it "DefaultStateConversionStrategy" do
				uri = Engine::State::DefaultStateConversionStrategy.state_to_uri({'name' => 'value', 'name2' => 'value2'})
				((uri == 'name/value/name2/value2') || (uri == 'name2/value2/name/value')).should be_true
      
				state = Engine::State::DefaultStateConversionStrategy.uri_to_state('name/value/name2/value2')
				state.should == {'name' => 'value', 'name2' => 'value2'}
			end
    
			it "AbsolutePathStateConversionStrategy" do
				Engine::State::AbsolutePathStateConversionStrategy.state_to_uri(Path.new('/one/two/three')).should == '/one/two/three'
				Engine::State::AbsolutePathStateConversionStrategy.uri_to_state('/one/two/three').should == Path.new('/one/two/three')
			end
    
			it "StateBuilder" do
				params = {'p0'=>'one/two', 'p1' => 'key/value', 'p2' => 'key2/value2', 'external_state' => 'external_state_value'}
      
				builder = Engine::State::StateBuilder.new params
				builder.convert PortletStub.new.set(:component_id => 'p0')
				builder.convert PortletStub.new.set(:component_id => 'p1')
				builder.convert PortletStub.new.set(:component_id => 'p2')
				state = builder.state
				state.should == {
					'p0' => {'one' => 'two'},
					'p1' => {'key' => 'value'},
					'p2' => {'key2' => 'value2'}
				}      
			end
	
#			it "URIBuilder main URI building" do
#				state = {
#					'p0' => {'one' => 'two'},
#					'p1' => {'key' => 'value'},
#					'p2' => {'key2' => 'value2'}
#				}
#				builder = Engine::State::URIBuilder.new state
#				builder.process PortletStub.new.set(:component_id => 'id')
#				builder.process PortletStub.new.set(:component_id => 'p1'), false
#				builder.process PortletStub.new.set(:component_id => 'p2'), false
#
#				builder.uri.should == "/?p0=one/two&p1=key/value&p2=key2/value2"
#			end		
#    
#			it "URIBuilder Form/Button/Link URI building" do
#				state = {
#					'p0' => {'one' => 'two'},
#					'p1' => {'key' => 'value'},
#					'p2' => {'key2' => 'value2'}
#				}
#				builder = Engine::State::URIBuilder.new state
#				builder.process PortletStub.new.set(:component_id => 'id'), true
#				builder.process PortletStub.new.set(:component_id => 'p1'), false
#				builder.process PortletStub.new.set(:component_id => 'p2'), false
#      
#				clone = builder.clone
#				clone.update PortletStub.new.set(:component_id => 'p1'), false, {'k' => 'v'}
#				clone.uri.should == "/?p0=one/two?p1=k/v&p2=key2/value2"
#      
#				clone = builder.clone
#				clone.update PortletStub.new.set(:component_id => 'p2'), false, {'k2' => 'v2'}
#				clone.uri.should == "/?p0=one/two?p1=key/value&p2=k2/v2"      
#			end				
		end
	end
end