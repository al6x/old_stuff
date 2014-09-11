class BrigeServlet
	extend Managed 
	include Log
	
	inject :session => Session,
	:static_resource => StaticResource,
	:resource => Resource,
	:window => Window
	
	HEADER = {		
		"Content-Type" => "text/html; charset=UTF-8",
		#		"Date" => nil,
		"Cache-Control" => "private, max-age=0", #"no-cache", 
		"Expires" => "-1"
	}
	
	SESSION_ID = "_sid"		
	
	attr_accessor :app_class, :base_uri
	
	def initialize app_class, base_uri = "ui", root_wportlet_id = nil
		@app_class, @base_uri, @root_wportlet_id = app_class, base_uri, root_wportlet_id
		
		Scope[BrigeServlet] = self
	end		
	
	def call env				
		req = Rack::Request.new(env)
		path = Path.new(Rack::Utils.unescape(req.path_info)).to_relative rescue Path.new("")		
		sid = req.params[SESSION_ID]
		uri = env['REQUEST_URI']	
		
		result = case
			when  req.get?
			if !path.empty? and path.first_name == STATIC_RESOURCE
				async_static_resource path
			elsif !path.empty? and path.first_name == RESOURCE
				async_resource path, req, sid
			else # GET
				sync_get path, req.params, sid, uri, req
			end
			when req.post?
			if !path.empty? and path.first_name == "__ajax_post__" # POST
				sync_post path, req, false, sid
			elsif !path.empty? and path.first_name == "__ajax_push__" # PUSH
				sync_push sid
			elsif !path.empty? and path.first_name == "__iframe_post__" # POST with files           	
				sync_post path, req, true, sid
			end
		end
		return result
	end
	
	protected
	def valid_sid? sid
		sid and MicroContainer::ScopeManager.include?(sid)		
	end
	
	def sync_get path, params, sid, uri, req					
		begin
			cookies_sid = req.cookies[SESSION_ID]
			unless valid_sid?(sid) and cookies_sid == sid # if it somehow delete it's cookies sid
				if sid == nil or !MicroContainer::ScopeManager.include?(sid)
					sid = Utils::Session.generate_id
					MicroContainer::ScopeManager.activate_thread sid do
						window.session_id = sid
					end
					
					new_params = {}
					params.each do |key, value| 
						next if key == SESSION_ID
						new_params[key] = value
					end					
					uri = State::URIBuilder.build_uri @base_uri, path.to_s, new_params, sid			
					
					resp = Rack::Response.new([], 301, {"Location" => uri, "Content-Type" => "text/html"})
					resp.set_cookie SESSION_ID, {:value => sid, :path => "/"}
					return resp.finish
				end
			end
			
			MicroContainer::ScopeManager.activate_thread sid do
				window.import_scripts_set CORE_IMPORT_SCRIPTS.clone # Reset scrits import								
				suri = session.uri
				sstate = session.state
				if session.uri != uri
					# Update State
					state_builder = State::StateBuilder.new path, params, @root_wportlet_id
					window.visit Visitors::UpdateState.new(state_builder)
					session.state = state_builder.state
					
					# Build Refreshed Wigets
					window.visit Visitors::BuildRefreshedWigets.new
					
					# Collect State
					collector = Visitors::CollectState.new
					window.visit collector
					
					# Build URIs
					uri_builder = State::URIBuilder.new collector.state, collector.conversion_strategies, @base_uri, @root_wportlet_id
					window.visit Visitors::SetUrls.new(uri_builder)
					
					session.uri = uri
					if session.state != collector.state or !state_builder.valid_uri?
						new_uri = uri_builder.build_uri
						session.state, session.uri = collector.state, new_uri
						return [301, {"location" => new_uri, "Content-Type" => "text/html"}, []]
					end
				end
				
				window.refresh
				html = window.visit(Visitors::CollectHTMLForRefreshedWigets.new).result[0][:html]
				
				# Remember imported scripts (it may be added in to_html)
				@import_scripts_size = window.import_scripts_get.size
				
				return [200, HEADER, [html]]
			end
		rescue Exception => e
			log.error e
			return [200, {"Content-Type" => "text/plain"}, ["Error: #{e.message}"]]
		end
	end
	
	def sync_post path, req, iframe, sid
		begin
			raise MicroContainer::InvalidSessionError, "Page has been expired! (Invalid Session ID '#{sid}'!)" unless valid_sid? sid
			
			params = req.params
			executor_id, action_name = path.next.to_a
			MicroContainer::ScopeManager.activate_thread sid do
				executor = window.visit(Visitors::FindById.new(executor_id)).result
				unless executor
					raise MicroContainer::InvalidSessionError, "Page has been expired! (Invalid executor ID '#{executor_id}'!)" 
				end
				# TODO validate input values
				executor.inputs_for(action_name).each do |input_wiget|
					input_wiget.visit(Visitors::UpdateValues.new(params))
				end
				executor.execute action_name
				
				# Build Refreshed Wigets
				window.visit Visitors::BuildRefreshedWigets.new
				
				json =  ajax_responce
				
				#				log.debug json
				unless iframe
					return [200, {"Content-Type" => "text/plain"}, [json]]
				else
					html = %{\
<html>
<head></head>
<body>
<textarea>#{json}</textarea>
</body>
</html>}
					return [200, {"Content-Type" => "text/html"}, [html]]
				end
			end
		rescue Exception => e
			log.error e
			unless iframe
				return [200, {"Content-Type" => "text/plain"}, [{:error => e.message}.to_json]]
			else
				html = %{\
<html>
<head></head>
<body>
<textarea>#{{:error => e.message}.to_json}</textarea>
</body>
</html>}
				return [200, {"Content-Type" => "text/html"}, [html]]
			end
		end
	end
	
	def sync_push sid
		begin
			raise MicroContainer::InvalidSessionError, "Page has been expired! (Invalid Session ID '#{sid}'!)" unless valid_sid? sid
			
			MicroContainer::ScopeManager.process_async_observers_for_session sid do
				# Build Refreshed Wigets
				window.visit Visitors::BuildRefreshedWigets.new
				
				json = ajax_responce
				return [200, {"Content-Type" => "text/plain"}, [json]]
			end
		rescue MicroContainer::InvalidSessionError => e
			raise e
		rescue Exception => e
			log.warn e
			return [200, {"Content-Type" => "text/plain"}, [{:error => e.message}.to_json]]
		end
	end
	
	def async_static_resource path
		begin						
			path_to_resource = path.after(STATIC_RESOURCE).to_relative
			
			sr = nil
			MicroContainer::ScopeManager.synchronize do
				sr = static_resource
			end
			
			res, header = sr.get_static_resource(path_to_resource)
			return [200, header, res]
		rescue Exception => e
			log.warn e
			return [200, {"Content-Type" => "text/plain"}, ["Error: #{e.message}"]]
		end
	end
	
	def async_resource path, req, uri_sid
		begin			
			sid = req.cookies[SESSION_ID] 
			sid = uri_sid unless sid or valid_sid? sid		
			raise MicroContainer::InvalidSessionError, "Page has been expired! (Invalid Session ID '#{sid}'!)" unless sid or valid_sid? sid			
			
			resource_id = path.after(RESOURCE).to_relative
			
			res = nil
			MicroContainer::ScopeManager.activate_thread sid, false do
				res = resource.get_resource(resource_id)
			end
			
			return [200, HEADER.merge({"Content-Type" => res.data.mime_type, "Content-Length" => res.data.size.to_s}),
			res.data]
		rescue RuntimeError => e
			log.info e
			return [200, {"Content-Type" => "text/plain"}, ["Error: #{e.message}"]]
		end
	end
	
	def ajax_responce
		# Collect State
		collector = Visitors::CollectState.new
		window.visit collector
		
		# Build URIs
		uri_builder = State::URIBuilder.new collector.state, collector.conversion_strategies, @base_uri, @root_wportlet_id
		window.visit Visitors::SetUrls.new(uri_builder)
		
		data = {}		
		if (session.state != collector.state)
			# Build redirect URI
			uri_builder = State::URIBuilder.new collector.state, collector.conversion_strategies, @base_uri, @root_wportlet_id
			new_uri = uri_builder.build_uri
			session.state, session.uri = collector.state, new_uri
			
			data[:redirect] = new_uri
		else
			data[:elements] = window.visit(Visitors::CollectHTMLForRefreshedWigets.new).result
			if (@import_scripts_size != window.import_scripts_get.size)
				data[:redirect] = session.uri
				data.delete :elements
			end
		end				
		data.to_json
	end
end
Scope.register BrigeServlet, :application