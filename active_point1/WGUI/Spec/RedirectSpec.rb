require 'WGUI/web_spec'
module WGUI
	module RedirectSpec
		class RedirectDuringStateUpdate < WComponent
			include WPortlet
		
			def initialize
				self.component_id = :ror
			end
		
			def update_state
				self.state = {'forum' => 'forum'}
			end
		end
	
		class RedirectOnAction  < WComponent
			include WPortlet
			children :@content
		
			def initialize
				self.component_id = :roa
				@content = Button.new('Redirect') do
					self.state = {'action' => 'action'}
				end
			end
		end
	
		class ClearInvalidState  < WComponent
			include WPortlet
		end
	
		register_wiget "should_redirect_during_action_phase" do
			RedirectOnAction.new
		end
	
		register_wiget "should redirect during state update" do
			RedirectDuringStateUpdate.new
		end
	
		register_wiget "should_clear_invalid_state" do
			ClearInvalidState.new.set(:component_id => :cis)
        end
		
		describe "WGUI Redirect" do
			it "should redirect during action phase" do
				go 'localhost:8080/?t=should_redirect_during_action_phase'
				uri.should_not =~  /localhost:8080\/\?roa=/ # Shouldn't display empty state'
				click 'Redirect'
				wait_for{uri =~ /action\/action/}
				click 'Redirect'
				wait_for{uri =~ /action\/action/}
			end

			it "should redirect during state update" do
				go 'localhost:8080/?t=should redirect during state update&ror=a/b'
				wait_for{uri =~ /forum\/forum/}
			end

			it "should clear invalid state" do
				go 'localhost:8080/?t=should_clear_invalid_state&invalid_id=a/b'
				wait_for{uri !~ /a\/b/ and uri !~ /invalid_id/}
			end
		end
	end
end