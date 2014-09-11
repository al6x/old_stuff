module WebClient
	Extension
	class Extension
		class << self					
			extend Injectable
			inject :controller => DomainModel::Engine::Controller,
      :layout_manager => DomainModel::Engine::LayoutManager,
      :storage => :storage
			
			def go_to path; 				
				controller.object = storage[path]					
			end
			
			def get_path object;
				storage.path_to object
			end
			
			def after_object object; 
				layout_manager.layout object
				controller.execute :on_view
			end
			
			def before_object object; 
			end
			
			def get_data_storage; 
				storage			
			end					
		end
	end
end