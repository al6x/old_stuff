class CollectHTMLForRefreshedWigets
	attr_reader :result
	
	def initialize; 
		@result, @visit_children = [], true
	end
	
	def accept wiget
		if wiget.refreshed?			
			wiget.visit TurnOffRefresh
			html = wiget.to_html			
			html = format(html) if $debug
			@result << { 
				:component_id => wiget.component_id,
				:html => html
			}						
			@visit_children = false
		end
	end		
	
	def visit_children?; @visit_children end
	
	def format html
		html
#		element = REXML::Document.new(html)
#		formatter = REXML::Formatters::Pretty.new 2
#		fhtml = ""
#		formatter.write element, fhtml
#		return fhtml
	end		
end