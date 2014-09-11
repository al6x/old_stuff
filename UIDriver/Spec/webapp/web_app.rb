#gem 'rack', '= 0.9.1'
#warn "Old Rack version"
require 'rack'
require 'rack/utils'

require 'sinatra/base'
require 'erb'

class Foo < Sinatra::Base
	enable :static
	set :public, File.dirname(__FILE__) + '/static'
	set :views, File.dirname(__FILE__) + '/views'
	
	#	enable :static , :session
	#	set :root, "#{File.dirname(__FILE__)}/html"
	
	# each subclass has its own private middleware stack:
	 use Rack::Session::Pool
	
	# instance methods are helper methods and are available from
	# within filters, routes, and views:
	#	def em(text)
	#    "<em>#{text}</em>"
	#	end
	#	
	#	# routes are defined as usual:
	#	get '/hello/:person' do
	#    "Hello " + em(params[:person])
	#	end
			
	get "/has_text" do
		sleep 1
		erb :has_text
	end
	
	get "/ajax_button" do
		sleep 1
		erb :ajax_button
	end
	
	get "/ajax_button_not_automated" do
		sleep 1
		erb :ajax_button_not_automated
	end
	
	post "/ajax_responce" do
		sleep 1
		"Content updated by AJAX"
	end
	
	get "/" do
		erb :index
	end
	
	post "/" do
		erb :index
	end
	
	get "/parallel_mode" do
		sleep 2
		erb :index
	end
	
	get "/:package/:template" do
		erb :"#{params[:package]}/#{params[:template]}"
	end		
	
	post "/:package/:template" do
		erb :"#{params[:package]}/#{params[:template]}"
	end
end

# WebServer Run
app = Rack::Handler::Mongrel.new Foo
server = Mongrel::HttpServer.new('0.0.0.0', 7000)
server.register('/', app)
webserver = server.run		
webserver.join
