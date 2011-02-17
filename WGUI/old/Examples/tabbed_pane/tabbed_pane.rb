require 'wgui/wgui'
include WGUI

module TabbedPane
	class TabbedPane < WComponent
		include WPortlet
		attr_accessor :pages
		
		def initialize
			super
			self.pages = {}		
			@tabs = Panel.new self
			@view = Panel.new self			
			template 'xhtml/TabbedPane'
		end
		
		def render			
			@tabs.childs.clear
			@view.childs.clear						
						
			page = nil
			if state['tab'] && (pages.include? state['tab'])
				page = pages[state['tab']]				
			elsif pages.size > 0
				page = pages.values.first
				state['tab'] = pages.keys.first
			else
				state.clear
			end
			
			@view.add page if page
							
			pages.each do |name, p|
				if p.object_id == page.object_id
					Label.new @tabs, name
				else
					Link.new @tabs, name, {'tab' => name}
				end
			end
		end
	end
	
	class RootComponent < WComponent
		def initialize
			@one = TabbedPane.new.set(	:component_id => 'one')
			@one.pages = {
				'one' => Label.new(nil, 'one one ...'),
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
	Runner.start TabbedPane::RootComponent
	Runner.join
end