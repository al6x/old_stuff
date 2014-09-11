class ForumView < WComponent
	include Managed	
	scope :session
	inject :service => ForumService
	
	def initialize
		super
		@topics = []
		@add = Button.new 'Add' do
			editor = TopicEditor.new.set(:topic => TopicModel.new)
			editor.on_ok = lambda do 
				service[editor.topic.name] = editor.topic				
			end
			subflow editor
		end			
	end
		
	# TODO reimplement via IOC Model Listhener
	def update
		@topics.clear
		service.keys.each do |name|
			@topics << Link.new(name, {'topic' => name, 'forum' => service.forum_name})
		end
	end								
end