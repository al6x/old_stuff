class BorderLayout
	inherit Entity
	
	metadata do
		name "Border Layout"
		reference :center, :bag		
		reference :left, :bag
		reference :top, :bag
		reference :right, :bag
		reference :bottom, :bag
		attribute :css, :object, :initialize => {}
	end
	
	def build_layout
		layout = WGUIExt::Containers::Border.new
		[:center, :left, :top, :right, :bottom].each do |pos|
			list = self.send pos			
			next if list.empty?
			
			box = WGUIExt::Containers::Box.new.set! :css => "padding"
			layout.add pos, box
			
			list.each do |wiget_def| 								
				wrapper = wiget_def.create_wiget_wrapper							
				
				if css_list = css[pos]
					wrapper.css = css_list[pos] if css_list[pos]
				end
				
				box.add wrapper
			end
		end
		return layout
	end		
end