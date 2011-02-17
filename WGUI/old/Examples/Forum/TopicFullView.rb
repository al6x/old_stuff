class TopicFullView < WComponent
	include Managed
	scope :session
	
	inject :service => ForumService,
		:portlet => Forum
	attr_accessor :topic
	
	def initialize
		super
		@back = Link.new 'topics' do |s| 
			s.delete 'topic'; s
		end
		@topic_view = TopicView.new
		@comments = []
		@comment = Button.new 'Comment' do
			editor = CommentEditor.new
			editor.on[:ok] = lambda do 
				topic.comments << editor.comment
			end
			subflow editor
		end			
			
		@topic_view.on_edit = lambda do
			subflow TopicEditor.new.set(
				:topic => topic, 
				:on[:ok] => lambda do
					service.update topic
					portlet.state['topic'] = topic.name
					portlet.notify_state
				end
			)
		end
		@topic_view.on_delete = lambda{
			service.delete topic.name
			portlet.refresh
		}
	end
		
	def topic= topic
		@topic_view.topic = topic
		@comments.clear					
		topic.comments.each do |cm|
			comment = CommentView.new
			comment.comment = cm
			comment.on_edit = lambda{
				portlet.subflow(CommentEditor.new.set(:comment => cm))
			}
			comment.on_delete = lambda do
				topic.comments.delete cm
				portlet.refresh
			end
			@comments << comment
		end
	end		
end