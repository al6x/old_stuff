class TopicEditor < WComponent
	attr_accessor :topic, :on_ok, :on_cancel
		
	def initialize
		super
		@name = TextField.new ""
		@text = TextArea.new ""			
		@ok = Button.new 'Ok', self do
			topic.name, topic.text = @name.text, @text.text
			on_ok.call if on_ok
			answer
		end			
		@cancel = Button.new 'Cancel' do
			on_cancel.call if on_cancel
			answer
		end		
	end
		
	def topic= topic
		@topic = topic
		@name.text, @text.text = topic.name, topic.text
	end
end