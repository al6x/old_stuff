require 'wgui/spec/examples/tabbed_pane/tabbed_pane'

module TabbedPane
  
	class SimpleForm < WComponent
		attr_accessor :label, :text
    
		def initialize
			super
			label = Label.new self, 'Set me ...'
			text = TextField.new self, ""
			Button.new self, 'Set', self do
				label.text = text.text
				label.refresh
			end
		end
	end
  
	class PortletsWithForms < WComponent
		def initialize
			@one = TabbedPane.new.set(:component_id => 'one')
			@one.pages = {
				'one' => SimpleForm.new,
				'two' => Label.new(nil, 'two two ...')
			}
			
			@two = TabbedPane.new.set(:component_id => 'two')
			@two.pages = {
				'one' => Label.new(nil, 'one one ...'),
				'two' => Label.new(nil, 'two two ...')
			}
			
			@three = TabbedPane.new.set(:component_id => 'three')
			@three.pages = {
				'one' => Label.new(nil, 'one one ...'),
				'two' => @two
			}
			
			@root = TabbedPane.new.set(:component_id => 'root')
			@root.pages = {
				'one' => @one,
				'two' => @three,
				'3' => Label.new(nil, 'Three')
			}
      
			childs << @root.set(:parent => self)
		end
	end
end

if __FILE__.to_s == $0
	Runner.start TabbedPane::PortletsWithForms
	Runner.join
end