require 'WGUI/web_spec'
module WGUI
	module RedirectSpec
		class PushRedirect < WComponent
			include WPortlet
			extend Managed
			scope :session
			children :@content
		
			def initialize
				@content = Label.new "PushRedirect"
				Scope.add_observer :msg, self, :execute_action
			end
			
			def execute_action
				self.state = {'a' => 'b'}
			end
		end
		
		class Container < WComponent
			include WPortlet
			extend Managed
			children :push_redirect
			inject :push_redirect => PushRedirect			
		end
		
		register_wiget "redirect_if_state_changed" do
			Container.new
		end

		class NewLabel < WComponent
			extend Managed
			scope :session
			children :@content

			def initialize
				@content = Label.new "The Text"
				Scope.add_observer :msg, self, :execute_action
			end

			def execute_action
				@content.text = "New Text"
			end
		end

		class Container2 < WComponent
			extend Managed
			children :new_label
			inject :new_label => NewLabel
		end
		
#start_webserver; join_webserver;		

		register_wiget "update page via AJAX" do
			Container2.new
		end

		describe "AJAX PUSH" do					
			it "redirect if state changed" do
				go 'localhost:8080/ui?t=redirect_if_state_changed'
				wait_for.should have_text('PushRedirect')
				uri.should_not =~ /a\/b/
							
				Scope.notify_observers :msg
				wait_for{uri =~ /a\/b/}
			end
			
			
		
			it "update page via AJAX" do
				go 'localhost:8080/ui?t=update page via AJAX'
				wait_for.should have_text('The Text')				
				
				Scope.notify_observers :msg	
				
				wait_for.should have_text('New Text')
			end
		end
	end
end