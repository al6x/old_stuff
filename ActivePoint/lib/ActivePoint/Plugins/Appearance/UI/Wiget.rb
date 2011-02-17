class Wiget
	inherit Controller
	editor EditWiget
	
	def show
		@view = show_wiget.set :object => C.object
	end
	
	def edit_wiget
		@view = EditWiget.new.set :object => C.object
		@view.on[:ok] = lambda do						
			R.transaction{C.object.set @view.values}.commit
			show
		end
		@view.on[:cancel] = lambda{show}
	end
	
	protected
	def show_wiget
		Form.common_form :box, :title => `Wiget`, :css => "padding" do
			attributes do
				add `Name`, :string_view, :attr => :name
				add `Wiget Class`, :string_view, :attr => :wiget_class, :before_read => lambda{|c| c ? c.name : ""}
				add `Accessor`, :string_view, :attr => :accessor, :before_read => lambda{|c| c ? c.to_s : ""}
				add `Parameters`, :text_view, :attr => :parameters, :before_read => lambda{|o| YAML.dump o}
			end
			button :text => `Edit`, :action => :edit_wiget
		end		
	end	
end