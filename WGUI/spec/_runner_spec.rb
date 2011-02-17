require 'WGUI/scripts/web_spec'

module WGUI
	module RunnerSpec  
		class RootComponent < WComponent
			children :@button
			
			def initialize
				@button = Button.new "Stop Server" do
					Runner.stop
				end
			end
		end	
		
		describe 'Runner' do		
			it 'should start and stop' do
				stop_webserver
		
				Thread.new{
					sleep 3

					go 'localhost'
					click(/Stop Server/)
				}
				Engine::Runner.start RootComponent
				Engine::Runner.join
			end
		end
	end
end