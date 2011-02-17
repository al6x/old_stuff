class Resources < WComponent
	children :@table, :@upload, :@add
	
	def initialize rich_text, editor, resources
		super()
		@rich_text, @editor, @resources = rich_text, editor, resources		
		@table, @upload, @add = [], nil, nil
	end
	
	def editor_id
		@editor ? @editor.editor_id : ""
	end
	
	def build
		@table = []
		@upload = FileUpload.new
		@add = Button.new "Add", @upload do
			if @rich_text.on_add_get
				@rich_text.on_add_get.call @upload
				refresh
			end
		end
		
		@resources.each do |resource_data|
			dbutton = Button.new "Delete" do
				if @rich_text.on_delete_get
					@rich_text.on_delete_get.call resource_data
					refresh
				end
			end
			@table << [WImage.new(resource_data), dbutton]
		end
	end
end