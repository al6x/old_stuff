class TopicView < WComponent
	attr_accessor :topic, :on_edit, :on_delete
		
	def initialize
		super
		@name = Label.new ""
		@text = Label.new ""
		@edit = Button.new('Edit'){on_edit.call if on_edit}
		@delete = Button.new('Delete'){on_delete.call if on_delete}            
	end
		
	def topic= topic
		@name.text, @text.text = topic.name, topic.text
	end
end