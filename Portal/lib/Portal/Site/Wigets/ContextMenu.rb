class ContextMenu < WComponent
	extend Managed
	scope :object
	
	children :@list, :@up
	
	MAX = 10
	
	# If has children it lists them and adds Up if not lists siblings
	def build
		@list, @up = [], nil
		index = 0
		
		C.object.each(:child) do |child|
			break if index >= MAX
			@list << new(:link, :text => text(child), :value => child)
			index += 1
		end
		
		parent = C.object.parent
		site = C.object.search_up{|o| o.is_a? Model::Site}
		if parent and parent != site
			@up = new(:link, :text => text(parent), :value => parent)
		end
		if @list.empty?
			parent.each(:child) do |child|
				break if index >= MAX
				@list << new(:link, :text => text(child), :value => child)
				index += 1
			end
		end		
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