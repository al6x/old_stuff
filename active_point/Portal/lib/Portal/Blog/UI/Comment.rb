class Comment
	inherit Controller
	editor EditComment
	
	def show
		@view = Form.common_form :box, :title => C.object.title, :object => C.object, :css => "padding" do
			richtext_view :attr => :content
		end
	end
end