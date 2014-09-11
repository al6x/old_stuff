class CommentEditor < WComponent
	attr_accessor :comment, :on_ok, :on_cancel
	
	def initialize
		super	
		@label = Label.new "Comment"
		@text = TextArea.new ""
		@ok = Button.new 'Ok', self do
			on_ok.call if on_ok
			answer
		end
		@cancel = Button.new self, "Cancel" do
			on_cancel.call if on_cancel
			cancel
		end
	end		
	
	def comment= comment
		@text.text = comment.text
    end
end