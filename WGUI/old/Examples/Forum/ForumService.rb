class ForumService < Hash
	include Managed
	scope :application
	attr_accessor :topics, :forum_name
		
	def initialize
		@forum_name = "General forum"
		self['A flight to the Moon'] = TopicModel.new.set(
			:name => 'A flight to the Moon', 
			:text => 'Is there any ability to travel to the Moon?', 
			:comments => [
				'I hope yes', 
				'man, you are crazy', 
				'yes, i did it esterday'						
			]
		)
		self['I like Terminator'] = TopicModel.new.set(
			:name => 'I like Terminator', 
			:text => 'I watch movie Terminator about 10 yars, and thin its cool', 
			:comments => [
				'Me too', 
				'I like Arnold'					
			]
		)
		self['Ninja'] = TopicModel.new.set(
			:name => 'Ninja', 
			:text => 'Im found new Ninja school', 
			:comments => [
				'Cool, man', 
				'forget it', 
				'this is crap'
			]
		)
	end
		
	def update new_topic
		self.each do |name, topic|
			if topic == new_topic
				delete name
				self[new_topic.name] = new_topic
			end
		end
	end
end