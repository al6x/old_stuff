module AreaMix
	def area_by_id id, &b
		id.should! :be_a, [String, Symbol]
		area single("//*[@id='#{id}']"), &b
	end
	
	def area_by_class klass, &b
		klass.should! :be_a, [String, Symbol]
		area single("//*[contains(@class,'#{klass}')]"), &b
	end
	
	def register_template template_name, url, areas
		areas.should! :be_a, Array
		
		go url
		hash = Hash.new{|h, k| "No Area '#{name}' in Template '#{template_name}'!"}
		@areas_by_template[template_name] = hash
		areas.each do |aname|
			aname.should! :be_a, String
			xpath = single(:text, /#{aname}/).first.xpath
			hash[aname] = xpath
		end		
	end
	
	def area_by_template template_name, area_name, &b
		xpath = @areas_by_template[template_name][area_name]
		area single(xpath), &b
	end
end