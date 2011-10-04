require 'wgui/wgui'
include WGUI
require 'wgui/spec/examples/forum/forum_components'
require 'wgui/spec/examples/forum/business_logic'

module Forum
	class TopicFullView < WComponent
		attr_accessor :service, :portlet, :topic
		def initialize parent
			super parent
			Link.new 'topics' do |s| 
				s.delete 'topic'; s
            end
			@topic_view = TopicView.new self
			@comments = Panel.new self
			Button.new self, 'Comment' do
				editor = CommentEditor.new.set(:comment => CommentModel.new)
				editor.on[:ok] = lambda do 
					topic.comments << editor.comment
					@comments.refresh
                end
				portlet.subflow editor
			end			
			
			@topic_view.on_edit = lambda{
				portlet.subflow TopicEditor.new.set(
					:topic => topic, 
					:on[:ok] => lambda do
						service.update topic
						portlet.state['topic'] = topic.name
						portlet.refresh
					end
				)
			}
			@topic_view.on_delete = lambda{
				service.delete topic.name
				portlet.refresh
			}
		end
		
		def render
			@topic_view.topic = topic
			@comments.childs.clear					
			topic.comments.each do |cm|
				comment = CommentView.new @comments
				comment.comment = cm
				comment.on_edit = lambda{
					portlet.subflow(CommentEditor.new.set(:comment => cm))
				}
				comment.on_delete = lambda do
					topic.comments.delete cm
					portlet.refresh
				end
			end
		end		
	end
	
	class ForumView < WComponent
		attr_accessor :service, :portlet
		def initialize parent
			super parent
			@topics = Panel.new self
			@add = Button.new self, 'Add' do
				editor = TopicEditor.new.set(:topic => TopicModel.new)
				editor.on[:ok] = lambda do 
					service[editor.topic.name] = editor.topic
					@topics.refresh
                end
				portlet.subflow editor
            end			
			template 'xhtml/ForumView'
		end
		
		def render
			@topics.childs.clear
			service.keys.each do |name|
				Link.new name, {'topic' => name, 'forum' => service.forum_name}
			end
		end								
	end
	
	class Forum < WComponent
		include WPortlet
		
		def initialize
			super
			@service = ForumService.instance 'general_forum'
			@forum = ForumView.new(self).set(:service => @service, :portlet => self)
			@topic = TopicFullView.new(self).set(:service => @service, :portlet => self)					
		end
		
		def render
			childs.clear	
			
			topic_name = state['topic']
			if topic_name && (topic_model = @service[topic_name])				
				@topic.topic = topic_model
				childs << @topic
			else	
				state.delete 'topic'
				childs << @forum
			end
			
			# there allways should be 'forum' = forum_name record
			state['forum'] = @service.forum_name
		end						
	end
end

if __FILE__.to_s == $0
	Runner.start Forum::Forum
	Runner.join
end