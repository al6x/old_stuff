class RestAdapter < Sinatra::Base	
	include Specification::Service
	
	post "/__eval__" do		
		translate do |user, method, code|
			code.should! :be_a, String
			raise SecurityError, "You haven't Permission!" unless user.administrator?

			eval code, TOPLEVEL_BINDING, __FILE__, __LINE__									
		end
	end	
	
	post "/*" do 		
		translate do |user, method, *args|
			path = params[:splat].join("/")		
			
			R.should! :include?, path			
			object = R[path]
			
			controller_class = Engine::Extensions.controller_for object, REST_NAME			
			controller_class.should! :be, RestController
			
			raise SecurityError, "You haven't Permission!" unless controller_class.can_execute_method? user, object, method
			
			controller = controller_class.new(object)
			controller.send method, *args
		end
	end		
end