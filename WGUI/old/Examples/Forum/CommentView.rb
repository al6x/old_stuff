class CommentView < WComponent
	attr_accessor :on_edit, :on_delete
	
	def initialize
		super
		@comment = Label.new ""
		@edit = Button.new("Edit"){ on_edit.call if on_edit }
		@delete = Button.new( 'Delete'){ on_delete.call if on_delete }
	end

	def comment= text
		@comment.text = text
    end
end