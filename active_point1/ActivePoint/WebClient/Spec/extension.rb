module WebClient				
	class Extension
		extend OpenConstructor
		
		class << self					
			attr_accessor :bget_path, :bget_object, :bgo_to, :bafter_object, :bget_data_storage
			
			def get_path object
				bget_path ? bget_path.call(object) : (object ? Path.new('object_path') : nil)
			end
			
			def get_data_storage
				bget_data_storage.call
			end
			
			def go_to path;
				if bgo_to
					bgo_to.call path
				else
					object = bget_object ? bget_object.call(path) : nil
					Scope[Controller].object = object
				end
			end
			
			def after_object object				
				bafter_object.call object if bafter_object
				#				else
				#					Scope[Engine::Window].layout = Extension.layout
				#					Scope[Engine:Controller].view = object_view
				#				end
			end												
		end
	end
end