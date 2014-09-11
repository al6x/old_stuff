require 'utils/open_constructor'

module Forum
	class CommentModel
		include OpenConstructor
		attr_accessor :text
    end
	
	class TopicModel
		include OpenConstructor
		attr_accessor :name, :text, :comments
		def initialize
			@name, @text, @comments = '', '', []
        end
	end		
	
	class ForumService < Hash
		attr_accessor :topics, :forum_name
		
		private_class_method :new
		def self.instance forum_name
			@instances ||= {}
			@instances[forum_name] ||= new forum_name
        end
		
		def initialize forum_name
			self.forum_name = forum_name
			self['A flight to the Moon'] = TopicModel.new.set(
				:name => 'A flight to the Moon', 
				:text => 'Is there any ability to travel to the Moon?', 
				:comments => [
					CommentModel.new.set(:text => 'I hope yes'), 
					CommentModel.new.set(:text => 'man, you are crazy'), 
					CommentModel.new.set(:text => 'yes, i did it esterday')						
				]
			)
			self['I like Terminator'] = TopicModel.new.set(
				:name => 'I like Terminator', 
				:text => 'I watch movie Terminator about 10 yars, and thin its cool', 
				:comments => [
					CommentModel.new.set(:text => 'Me too'), 
					CommentModel.new.set(:text => 'I like Arnold')					
				]
			)
			self['Ninja'] = TopicModel.new.set(
				:name => 'Ninja', 
				:text => 'Im found new Ninja school', 
				:comments => [
					CommentModel.new.set(:text => 'Cool, man'), 
					CommentModel.new.set(:text => 'forget it'), 
					CommentModel.new.set(:text => 'this is crap')
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
end