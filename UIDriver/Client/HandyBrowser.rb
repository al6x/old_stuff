class HandyBrowser < Browser			
	include AttributeMix, AreaMix, ControlMix	
	
	alias :has_the? :has?		
	
	def initialize *args
		super
		@areas = []
		@areas_by_template = Hash.new{|h, k| raise "Template '#{key}' not registered!"}
	end
	
	def has_text? text
		has? :text, text
	end
	
	def click text
		if has? :button, text
			single(:button, text).click
		elsif has? :link, text
			single(:link, text).click
		else
			raise "No Link or Button with '#{text}'!"
		end
	end
	
	def area list, &b		
		b.should_not! :be_nil

		begin
			@areas << list
			b.call
		ensure
			@areas.pop
		end
	end		
	
	alias :original_xpath_list :xpath_list
	def xpath_list *args
		list = original_xpath_list *args
		apply_areas(list)
	end	
	
	alias :original_filter :filter
	def filter *args
		list = original_filter *args
		apply_areas(list)
	end		
	
	def cell col, row, type = :any, text = ""
		col = col.is_a?(Browser::ResultSet) ? col : single(:text, col)
		row = row.is_a?(Browser::ResultSet) ? row : single(:text, row)
		
		value = list(type, text).filter(:cell, col, row)
		raise "Can't find Attribute Value!" if value.size < 1
		raise "Found more than one Attribute Values!" if value.size > 1
		return value
	end		
	
	def should_have *args
		should RSpecExtension.have(self, *args)
	end
	
	def should_not_have *args
		should_not RSpecExtension.have(self, *args)
	end			
	
	protected
	def apply_areas list
		@areas.inject(list){|result, area| original_filter :inside, result, area}
	end
end