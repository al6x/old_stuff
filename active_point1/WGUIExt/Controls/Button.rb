class Button < WButton
	include Control			
#	attr_accessor :metadata
	
	def initialize
		super
		self.style = "font"
	end				
	
	#  alias_method :old_text, :text
	#  def text
	#    return old_text if old_text and !old_text.empty?
	#    Button.label_resolver.call metadata, name
	#  end
	#  
	#  alias_method :old_action, :action
	#  def action
	#    return old_action if old_action
	#    Button.action_resolver.call metadata, name
	#  end
	#	
	#  class << self
	#    attr_accessor :label_resolver, :action_resolver
	#  end
end
