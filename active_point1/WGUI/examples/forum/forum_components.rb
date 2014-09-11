require 'wgui/wgui'
include WGUI

module Forum
	class CommentEditor < WComponent
		attr_accessor :comment, :on_ok, :on_cancel
		def initialize
			super	
			Label.new self, "Comment"
			@text = TextArea.new self, ""
			Button.new self, 'Ok', self do
				comment.text = @text.text
				on_ok.call if on_ok
				answer
            end
			Button.new self, "Cancel" do
				on_cancel.call if on_cancel
				answer
            end
        end
		
		def render
			@text.text = comment.text
        end		
    end
	
	class CommentView < WComponent
		attr_accessor :comment, :on_edit, :on_delete
		
		def initialize parent
			super parent
			@text = Label.new self, ""
			@edit = Button.new(self, "Edit"){ on_edit.call if on_edit }
			@delete = Button.new(self, 'Delete'){ on_delete.call if on_delete }
			template "xhtml/CommentView"
        end
		
		def render
			@text.text = comment.text
        end	
    end
	
	class TopicEditor < WComponent
		attr_accessor :topic, :on_ok, :on_cancel
		
		def initialize
			super
			@name = TextField.new self, ""
			@text = TextArea.new self, ""			
			@ok = Button.new self, 'Ok', self do
				topic.name, topic.text = @name.text, @text.text
				on_ok.call if on_ok
				answer
            end			
			@cancel = Button.new self, 'Cancel' do
				on_cancel.call if on_cancel
				answer
            end
			
			template 'xhtml/TopicEditor'			
        end
		
		def render
			@name.text, @text.text = topic.name, topic.text
        end		
    end
	
	class TopicView < WComponent
		attr_accessor :topic, :on_edit, :on_delete
		
		def initialize parent
			super parent
			@name = Label.new self, ""
			@text = Label.new self, ""
			@edit = Button.new(self, 'Edit'){on_edit.call if on_edit}
			@delete = Button.new(self, 'Delete'){on_delete.call if on_delete}            
			template 'xhtml/TopicView'
        end
		
		def render
			@name.text, @text.text = topic.name, topic.text
        end
    end
end