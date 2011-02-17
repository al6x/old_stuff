class Appearance
	inherit Controller
	
	def show
		@view = ShowAppearance.new.set :object => C.object
	end
	
	def add_layout		
		# Select Layout Class
		@view = Form.common_dialog do
			add nil, :select, :attr => :value, :values => object[:values]
		end
		layouts_classes = Model::Appearance::LAYOUTS_DEFINITIONS.map{|l| l.meta.name}
		layouts_classes.should_not! :empty?
		@view.object = {:value => layouts_classes[0], :values => layouts_classes, :title => `Select Layout Class`}
		@view.on[:ok] = lambda do						
			class_name = @view[:value].value
			raise `Class not selected!` if class_name.empty?
			klass = Model::Appearance::LAYOUTS_DEFINITIONS[layouts_classes.index(class_name)]
			
			# Create New Layout
			R.transaction_begin
			new_layout = nil			
			R.transaction{new_layout = klass.new}
			@view = C.editor_for new_layout
			@view.object = new_layout
			@view.on[:ok] = lambda do					
				R.transaction{
					new_layout.set @view.values				
					new_layout.validate
					
					C.object.layouts << new_layout
				}.commit	
				show
			end
			@view.on[:cancel] = lambda{show}
		end
		@view.on[:cancel] = lambda{show}			
	end
	
	def delete_layouts
		R.transaction_begin
		R.transaction{
			@view[:layouts].selected.every.delete
		}.commit
		show
	end
	
	def add_wiget
		R.transaction_begin
		new_wiget = nil
		R.transaction{new_wiget = Model::Wiget.new}
		@view = C.editor_for new_wiget
		@view.on[:ok] = lambda do					
			R.transaction{
				new_wiget.set @view.values				
				new_wiget.validate
				
				C.object.wigets << new_wiget
			}.commit	
			show
		end
		@view.on[:cancel] = lambda{show}
		@view.object = new_wiget
	end
	
	def delete_wigets
		R.transaction_begin
		R.transaction{@view[:wigets].selected.every.delete}.commit
		show
	end
end