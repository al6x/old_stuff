class NewsTool < CPView
	attr_accessor :news
	build_view do |v|
		form = v.create :box
		form.set :padding => true, :title => "News", :border => true
		v.root = form
		
		v.news.reverse_each do |item|			
			link = v.create :reference
			link.value = item.link
			
			text = v.create :text_view
			text.value = item.text
			
			date = v.create :date_view
			date.value = item.date
			
			flow = v.create :flow
			flow.add date			
			flow.add WLabel.new("-")
			flow.add link						
			
			container = v.create :box
			container.padding = true
			container.add flow
			container.add text
			form.add container			
		end
	end
end