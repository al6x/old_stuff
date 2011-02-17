class News < WComponent	
	extend Managed
	scope :object
	
	attr_accessor :wiget_id, :size, :path, :title, :symbol_limit
	attr_accessor :title_accessor, :content_accessor, :date_accessor
	
	children :@titles, :@contents, :@dates
	
	def initialize
		super
		@size, @symbol_limit = 3, 150
		@title_accessor, @content_accessor, @date_accessor = :title, :content, :date
	end
	
	def build		
		@title = `NEWS`
		@titles, @contents, @dates = [], [], []
		if path and R.include?(path)
			source = R[path]
			children = []
			source.each(:child){|c| children << c}
			latest = children.sort(&lambda{|a, b| b.send(date_accessor) <=> a.send(date_accessor)})[0..size-1]
			latest.map! do |o|
				title, content, date = o.send(title_accessor), o.send(content_accessor), o.send(date_accessor)
				
				title.should! :be_a, String 
				content.should! :be_a, String
				date.should! :be_a, DateTime
				
				@titles << new(:link, :text => title, :value => o)
				content = content[0..symbol_limit] + "..." if content.size > symbol_limit
				@contents << new(:string_view, :value => content, :no_escape => true)
				@dates << new(:date_view, :value => date)
			end	
		end
	end		
end