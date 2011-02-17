class Shortcuts < WComponent
	extend Managed
	scope :object
	
	attr_accessor :wiget_id	
	
	children :@links, :@buttons, :@add
	
	def build
		wiget_id.should_not! :be_nil
		
		wiget = R.by_id wiget_id
		current_id = C.object.entity_id
		
		@links, @buttons = [], []
		@index = nil
		if wiget.storage
			wiget.storage.each_with_index do |id, index| 
				begin 
					o = R.by_id id
				rescue NotFoundError # Entity has been deleted.
					next
				end
				
				unless id == current_id
					@links << new(:link, :text => o.name, :value => o)
				else					
					@index = index
					@links << WLabel.new(o.name).set(:style => "nowrap")
				end
				@buttons << new(:link_button, :text => "[x]", :action => lambda{delete_item id})
			end
		end
		
		@add = if @index == nil
			new :link_button, :text => `[Add]`, :action => lambda{add_item}
		end
	end
	
	def visible?
		super and C.can?(:shortcuts)
	end
	
	def add_item
		wiget = R.by_id wiget_id
		R.transaction{
			wiget.storage ||= []
			
			links = wiget.storage.dup
			links << C.object.entity_id
			links.delete_if{|id| !R.include_id?(id)}
			
			wiget.storage = links			
		}.commit
		refresh
	end
	
	def delete_item id
		wiget = R.by_id wiget_id
		R.transaction{
			links = wiget.storage.dup
			links.delete id
			links.delete_if{|id2| !R.include_id?(id2)}
			
			wiget.storage = links									
		}.commit
		refresh
	end
end