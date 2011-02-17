require 'WGUI/web_spec'

module WGUI
	module ErrorsSpec
		register_wiget "Should disable links that points to the same page" do
			class DisabledLinksPortlet < WComponent
				include WPortlet
				
				children :@label, :@link
				
				def initialize
					super
					self.component_id = "portlet"
					@label = Label.new
					@link = Link.new "Link", {'a' => 'b'}
				end
				
				def update_state
					@label.text = state.to_s
				end
			end
			DisabledLinksPortlet.new
		end
		
		register_wiget "Should correct display link with hash (a => b) state" do
			class HashPortlet < WComponent
				include WPortlet
				
				def initialize
					super
					self.component_id = "portlet"
					@label = Label.new
					@link = Link.new "Link", {'a' => 'b'}
				end
				
				def update_state
					@label.text = state.to_s
				end
			end
			HashPortlet.new
		end
		
		register_wiget "Should redirect from incorrect URI to correct one" do
			class RedirectPortlet < WComponent
				include WPortlet
				
				def initialize
					self.component_id = "portlet"
				end
			end
			RedirectPortlet.new
		end
		
		register_wiget "Should correct display link with path (/a/b/c) state" do
			class PathPortlet < WComponent
				include WPortlet
				
				def initialize
					super
					self.component_id = "portlet"
					@label = Label.new
					@link = Link.new "Link", Path.new('/a/b/c')
				end
				
				def update_state
					@label.text = state
				end
				
				def self.state_conversion_strategy;
					Engine::State::AbsolutePathStateConversionStrategy
				end
			end
			PathPortlet.new
		end
		
		register_wiget "Should always correct setup state, even if its empty" do
			class CorrectState < WComponent
				include WPortlet
				
				def initialize
					super
					self.component_id = "portlet"
					@label = Label.new
				end
				
				def update_state
					@label.text = "'#{state}'"
				end
				
				def self.state_conversion_strategy;
					Engine::State::AbsolutePathStateConversionStrategy
				end
			end
			CorrectState.new
		end
		
		register_wiget "Error when build an Link with empty operator attribute" do
			class LinkErrorSpec < WComponent
				def initialize
					@link = Link.new "Text on link"
				end
			end
			LinkErrorSpec.new
		end
		
		register_wiget "build builds ordinary wigets but doesn't build links" do
			class DoesntBuildLinks < WComponent
				include WPortlet
				
				def build
					@link = Link.new "Text on link", 'a' => 'b'
				end
			end
			DoesntBuildLinks.new
		end
		
#		register_wiget "When two Wigets directly beneath the same Container are refreshed it displys changes only in one of them" do
#			class InnerContainer < WComponent
#				attr_accessor :label
#			end
#			class TheSameContainer < WComponent				
#				def initialize
#					super
#					@l1 = Label.new "l1"
#					l2 = Label.new "l2"
#					@ic = InnerContainer.new.set :label => l2
#					@l3 = Label.new "l3"
#					@b = Button.new "Update" do
#						@l1.text = "l1 updated"
#						l2.text = "l2 updated"
#						@l3.text = "l3 updated"
#					end
#				end
#			end
#			TheSameContainer.new
#		end
		
		
#						start_webserver; join_webserver;
		
		describe "WGUI Redirect" do
			it "When two Wigets directly beneath the same Container are refreshed it displys changes only in one of them" do
				
			end
			
			it "Should disable links that points to the same page" do
				go 'localhost:8080/ui?t=Should disable links that points to the same page&portlet=c/d'
				wait_for.should have_text('cd')
				click 'Link'
				wait_for.should have_text('ab')
				wait_for.should have_text('Link')
				wait_for{!has_the? :link => 'Link'}
			end
			
			it "Should correct display link with hash (a => b) state" do
				go 'localhost:8080/ui?t=Should correct display link with hash (a => b) state&portlet=n/v'
				wait_for.should have_text('nv')
				click 'Link'
				wait_for.should have_text('ab')
				wait_for{!has_text?('nv')}
			end
			
			it "Should redirect from incorrect URI to correct one" do
				go 'localhost:8080/ui?t=Should redirect from incorrect URI to correct one&portlet=name/value/invalid'
				wait_for{uri !~ /invalid/}
				
				go 'localhost:8080/ui?t=Should redirect from incorrect URI to correct one&portlet=invalid'
				wait_for{uri !~ /invalid/}
			end
			
			it "Should correct display link with path (/a/b/c) state" do
				go 'localhost:8080/ui?t=Should correct display link with path (/a/b/c) state&portlet=/somepath'
				wait_for.should have_text('/somepath')
				click 'Link'
				wait_for.should have_text('/a/b/c')
			end
			
			it "Should always correct setup state, even if its empty" do
				go 'localhost:8080/ui?t=Should always correct setup state, even if its empty'
				wait_for.should have_text("'/'")
				go 'localhost:8080/ui?t=Should always correct setup state, even if its empty&portlet=/a/b'
				wait_for.should have_text("'/a/b'")
			end
			
			it "Error when build an Link with empty operator attribute" do
				go 'localhost:8080/ui?t=Error when build an Link with empty operator attribute'
			end
			
			it "build builds ordinary wigets but doesn't build links" do
				go "localhost:8080/ui?t=build builds ordinary wigets but doesn't build links"
				wait_for{has_the?(:link => 'Text on link')}
			end
		end
	end
end