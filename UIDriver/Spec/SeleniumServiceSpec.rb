require 'UIDriver/Client/require'
require 'spec'

module UIDRiver				
	module ServiceSpec # don't delete this module
		describe 'Service' do								
			Service = UIDriver::Client::Service
			Browser = UIDriver::Client::Browser
			
			before :each do
				UIDriver::Client::CONFIG.merge!\
				:timeout => "0.5",				
				:browser_expires => "30",				
				:retry_timeout => "0.01"
				
				Service.configure\
				:browsers_pool_size => "1",
				:max_browsers => "2",
				:check_expired_browsers_timeout => "10"
				
				Service.release_all				
			end
			
			after :each do
				Service.release_all
				restore_config = {}
				[:browsers_pool_size, :max_browsers, :check_expired_browsers_timeout].each do |name|
					restore_config[name] = UIDriver::Service["config.yaml"][name].to_s
				end
				
				Service.configure restore_config
			end
			
			after :all do
				# It should works
				Browser.new
			end
			
			it "Should Rent & Release Browser" do
				b = Browser.new
				b.close
			end
			
			it "Should raise error if max browsers exeeded" do				
				Browser.new
				Browser.new
				lambda{Browser.new}.should raise_error(/No avaliable Browsers/)
			end
			
			it "Mass Rent/Release cycle" do
				10.times do
					b = Browser.new
					b.close rescue{}
				end
				
				Service.configure :browsers_pool_size => "2"
				t1 = Thread.new do
					10.times do
						b = Browser.new
						b.close rescue{}
					end
				end
				t2 = Thread.new do
					10.times do
						b = Browser.new
						b.close rescue{}
					end
				end		
				t1.join; t2.join
			end
			
			it "Should execute tasks in parallel" do
				UIDriver::Client::CONFIG[:timeout] = "4"
				
				b1 = Browser.new
				b2 = Browser.new
				
				start_time = Time.now
				t1 = Thread.new do
					b1.go "localhost:7000/service/parallel_mode"
				end
				t2 = Thread.new do
					b2.go "localhost:7000/service/parallel_mode"
				end	
				t1.join; t2.join
				time = Time.now - start_time
				(1..3).should include(time)
			end
		end
	end		
end
