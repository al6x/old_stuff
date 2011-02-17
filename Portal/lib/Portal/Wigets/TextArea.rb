class TextArea < WComponent	
	extend Managed
	scope :object
	
	attr_accessor :wiget_id
	
	children :@content_wiget, :@edit
	
	def build
		@content_wiget, @link_wiget = nil, nil		
		
		wiget_id.should_not! :be_nil
		wiget = R.by_id wiget_id
		if storage = wiget.storage
			@title = storage[:title]
			@content_wiget = new :richtext_view, :value => storage[:content]
		end
		
		@edit = if C.can? :edit
			new :link_button, :text => `[Edit]`, :action => lambda{edit}
		else
			nil
		end
	end
	
	def edit		
		wiget = R.by_id wiget_id
		storage = wiget.storage || {:title => "", :content => WGUIExt::Editors::RichTextData.new}
		
		editor = Editor.new.set :object => storage.dup
		editor.on[:ok] = lambda do
			R.transaction{								
				wiget.storage = editor.values
			}.commit
			editor.cancel
			refresh	
		end
		editor.on[:cancel] = lambda{editor.cancel}
		subflow editor		
	end
end