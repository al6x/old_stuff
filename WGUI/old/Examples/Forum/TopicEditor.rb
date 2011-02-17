class TopicEditor < WComponent
	attr_accessor :topic, :on[:ok], :on[:cancel]
		
	def initialize
		super
		@name = TextField.new ""
		@text = TextArea.new ""			
		@ok = Button.new 'Ok', self do
			topic.name, topic.text = @name.text, @text.text
			on[:ok].call if on[:ok]
			answer
		end			
		@cancel = Button.new 'Cancel' do
			on[:cancel].call if on[:cancel]
			answer
		end		
	end
		
	def topic= topic
		@topic = topic
		@name.text, @text.text = topic.name, topic.text
	end
end