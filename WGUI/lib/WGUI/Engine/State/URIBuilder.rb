class URIBuilder			
	extend Injectable
	inject :window => Engine::Window
	
	def initialize state, conversion_strategies, base_uri, root_wportlet_id = nil
		@base_uri, @root_wportlet_id = base_uri, root_wportlet_id
		@state, @conversion_strategies = state, conversion_strategies
		
		@half_state = {}
		@state.sort.each do |id, s|			
			@half_state[id] = conversion_strategies[id].state_to_uri(s)
		end
	end
	
	def build_uri half_state = nil
		path, params = "", {}
		merged_state = half_state ? @half_state.merge(half_state) : @half_state
		merged_state.sort.each do |id, part|			
			if @root_wportlet_id and @root_wportlet_id == id 
				path = part
			else
				params[id] = part
			end
		end		
		
		return URIBuilder.build_uri @base_uri, path, params, window.session_id
	end
	
	def evaluate_uri portlet_component_id, link_state, alter_state
		#		return @cache[link_component_id] if @cache.include? link_component_id
		portlet_state = @state[portlet_component_id]
		if link_state
			link_state = link_state
		elsif alter_state
			link_state =  alter_state.call portlet_state.clone
		else
			link_state = portlet_state
		end
		
		if link_state != portlet_state		
			link_half_state = @conversion_strategies[portlet_component_id].state_to_uri(link_state)
			return build_uri({portlet_component_id => link_half_state})
		else
			return nil
		end
		#		@cache[link_component_id] = uri
	end
	
	class << self
		def build_uri base_uri, path, hash_params, sid
			path.should!(:be_a, String).should_not!(:=~, /^\//)
			params = []
			hash_params.each{|key, value| params << "#{key}=#{value}"}
			params << "#{Engine::BrigeServlet::SESSION_ID}=#{sid}"
			uri = URI.escape "#{base_uri}/#{path if path}#{'?' if params.size > 0}#{params.join('&')}"
			uri.should_not! :=~, /\/\//
			return uri
		end
		
		def static_resource_uri path			
			path.should!(:be_a, String).should_not!(:=~, /^\//)
			uri = URI.escape "#{Scope[BrigeServlet].base_uri}/#{STATIC_RESOURCE}/#{path}"
			uri.should_not! :=~, /\/\//
			return uri
		end
		
		def resource_uri component_id
			sid = Scope[Engine::Window].session_id
			URI.escape "#{Scope[BrigeServlet].base_uri}/#{RESOURCE}/#{component_id}?#{Engine::BrigeServlet::SESSION_ID}=#{sid}"
		end
	end
end