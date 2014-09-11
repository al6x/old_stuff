require 'WGUI/scripts/web_spec'

class WebserverStub
	def call(env)
		session = env['rack.session']
		session[1] ||= 0
		session[1] += 1		
		[200, {"Content-Type" => "text/html"}, ["Hello world! #{session[1]}"]]
	end
end

describe "General webserver functional" do
	before :each do
		start_webserver WebserverStub.new
	end
	
	it "session support" do		
		page = $browser.get 'http://localhost'
		page.body.include?('1').should be_true
		page = $browser.get 'http://localhost'
		page.body.include?('2').should be_true
		
		browser2 = WWW::Mechanize.new
		page = browser2.get 'http://localhost'
		page.body.include?('1').should be_true
	end	
	
	it "general response" do
		page = $browser.get 'http://localhost'
		page.body.include?('Hello world').should be_true
	end	
	
	after :each do
		stop_webserver
	end
end