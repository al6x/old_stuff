class CommentEditor < WComponent
	attr_accessor :comment, :on[:ok], :on[:cancel]
	
	def initialize
		super	
		@label = Label.new "Comment"
		@text = TextArea.new ""
		@ok = Button.new 'Ok', self do
			on[:ok].call if on[:ok]
			answer
		end
		@cancel = Button.new self, "Cancel" do
			on[:cancel].call if on[:cancel]
			cancel
		end
	end		
	
	def comment= comment
		@text.text = comment.text
    end
end