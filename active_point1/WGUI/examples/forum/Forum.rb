class Forum < WComponent
	include WPortlet, Managed
	scope :session
	inject :service => ForumService,
		:forum => ForumView,
		:topic => TopicFullView
	attr_accessor :state
	
	childs :@content
		
	def initialize
		super
		self.component_id = 'forum'
		@content = WContinuation.new
	end
		
	def update_state			
		topic_name = state['topic']
		if topic_name && (topic_model = service[topic_name])				
			topic.topic = topic_model
			@content.original = topic
		else	
			state.delete 'topic'
			forum.update
			@content.original = forum
		end
			
		state['forum'] = service.forum_name	
	end			
end