require 'wgui/wgui'
include WGUI

require 'utils/open_constructor'
include Utils

require 'wgui/spec/examples/wiki/business_logic'
require 'wgui/spec/examples/wiki/wiki_page'

class WikiMenu < WComponent	
	def initialize p
		super
		template 'xhtml/Menu'
    end
	def render
		childs.clear
		WikiService.instance.values.each do |m|
			Link.new self, m.name, {'page' => m.name}
		end
	end
end
	
class Wiki < WComponent
	include WPortlet		
	
	def initialize
		super
		@menu = WikiMenu.new self
		@view = WikiPage.new self
		template 'xhtml/Wiki'
	end
		
	def render
		@view.model = @model ||= WikiService.instance.home
	end
	
	def state= state
		current_page = state['page']
		service = WikiService.instance
		
		if current_page == 'home'
			@model = service.home
		else
			@model = service[current_page] || service.home
		end
	end
	
	def state; {'page' => @model.name} end
end

if __FILE__.to_s == $0
	Runner.start Wiki
	Runner.join
end