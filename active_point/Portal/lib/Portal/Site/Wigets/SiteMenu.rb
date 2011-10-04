class SiteMenu < WComponent	
	extend Managed
	scope :object
	
	children :@level1, :@level2
	
	MAX = 10
	
	def build
		@level1, @level2, @active = [], [], nil
		site = C.object.search_up{|o| o.is_a? Model::Site}
		return unless site
		
		index = 0
		site.each(:child) do |child|						
			if child == C.object.search_up{|o| o == child}
				if C.object == child
					@level1 << WLabel.new(text(child))
				else
					@level1 << new(:link, :text => text(child), :value => child)				
				end
				@active = index
			else
				@level1 << new(:link, :text => text(child), :value => child)				
			end			
			index += 1
			break if index > MAX
			
			l2 = []
			@level2 << l2
			index2 = 0
			child.each(:child) do |child2|				
				l2 << new(:link, :text => text(child2), :value => child2)
				
				index2 += 1
				break if index2 > MAX	
			end
		end
		
		#		site.menu.each_with_index do |path, index|
		#			o = begin 
		#				R[path]
		#			rescue ObjectModel::NotFoundError
		#				next
		#			end
		#			
		#			text = o.respond_to(:menu) || o.name
		#			
		#			unless o == C.object
		#				@menu << new(:link, :text => text, :value => o)
		#			else
		#				@menu << WLabel.new(text)
		#				@active = index
		#			end
		#		end
	end
	
	protected
	def text o
		mtext = o.respond_to(:menu) 
		if mtext and !mtext.empty?
			mtext
		else
			o.name				
		end
	end
end