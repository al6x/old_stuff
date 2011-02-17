module Container
	inherit Controller
	
	def container_add
		restore = @view
		# Select Layout Class
		@view = Form.common_dialog do
			add nil, :select, :attr => :value, :values => object[:values]
		end
		content_types = Model::Container::CONTENT_TYPES.map{|l| l.meta.name}
		content_types.should_not! :empty?
		@view.on[:ok] = lambda do						
			class_name = @view[:value].value
			class_name.should_not! :empty?
			klass = Model::Container::CONTENT_TYPES[content_types.index(class_name)]
			
			# Create New Content
			R.transaction_begin
			new_content = nil			
			R.transaction{new_content = klass.new}
			@view = C.editor_for klass
			@view.object = new_content
			@view.on[:ok] = lambda do					
				R.transaction{
					new_content.set @view.values				
					new_content.validate
					
					C.object.items << new_content
				}.commit	
				@view = restore
				@view.object = C.object
			end
			@view.on[:cancel] = lambda{@view = restore; @view.refresh;}
		end
		@view.on[:cancel] = lambda{@view = restore; @view.refresh;}				
		@view.object = {
			:value => content_types[0], :values => content_types, 
			:title => Portal::Aspects.to_l("Select Content Type")
		}
	end
	
	def container_delete
		R.transaction_begin
		R.transaction{@view.aspects[:container][:items].selected.every.delete}.commit
		@view.object = C.object
	end
	
	secure :container_add => :create,
	:container_delete => :delete
end