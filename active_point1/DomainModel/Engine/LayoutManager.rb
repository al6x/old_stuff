class LayoutManager
	include Log
	extend Managed
	scope :session
	
	def layout object				
		Scope[WebClient::Engine::Window].layout = begin
			layout = object.up :layout			
			layout.build_layout object			
		rescue NoMethodError => e
			log.error "Can't find layout for #{object}"
			if e.message =~ /layout/
				log.error e
			else
				raise e
			end
			nil
		end
	end
end