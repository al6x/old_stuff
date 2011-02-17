#module WContinuation
#	METHODS_TO_OVERRIDE = [
#	ExecutableWiget, WComponent, InputWiget, Wiget, WigetContainer, WPortlet
#	].inject(Set.new){|set, klass|
#		klass_methods = klass.instance_methods - klass.inherited_instance_methods
#		set.merge klass_methods
#	}.sort		
#	
#	METHODS_TO_OVERRIDE.each do |method|
#		params = (method =~ /=/) ? "*args" : "*args, &b"
#		
#		script = %{\
#	def #{method} #{params}
#		if _stack.size > 0
#			_stack.last.#{method} #{params}
#		else
#			super
#		end
#	end}		
#		
#		eval script, binding, __FILE__, __LINE__
#	end		
#	
#	def reset
#		_stack.clear
#		_actions.clear    
#	end
#	
#	def method_missing m, *args, &b
#		if _stack.size > 0 
#			_stack.last.send m, *args, &b
#		else
#			super
#		end		
#	end
#	
#	def respond_to? m
#		if _stack.size > 0 
#			_stack.last.send m, *args, &b
#		else
#			super
#		end		
#	end
#	
#	def subflow wiget, &answer_action
#		raise "Subflow component should be Wiget but is '#{wiget.class.name}'" unless wiget.is_a? Wiget
#		
#		wiget.component_id = component_id
#		
#		_stack << wiget
#		_actions << answer_action
#		
#		refresh
#	end
#	
#	def answer value = nil
#		raise "There is no subflow!" unless _stack.size > 0
#		
#		_stack.pop
#		action = _actions.pop
#		action.call value if action
#		
#		refresh
#	end
#	
#	def cancel
#		raise "There is no Subflow!" unless _stack.size > 0
#		
#		_stack.pop
#		_actions.pop		
#		
#		refresh
#	end
#	
#	def _stack
#		@_stack ||= []
#	end
#	
#	def _actions
#		@_actions ||= []
#	end
#end

class WContinuation < WComponent
  children :content
  
  attr_accessor :original
  
  def initialize original = nil
    super()
    @stack, @actions, @original = [], [], original
  end
  
  def reset
    @stack.clear
    @actions.clear    
  end
  
  def method_missing(m, *args)
    current = content    
    if current.respond_to? m
      current.send(m, *args)
    else
      super
    end
  end
  
  def respond_to? m
    super or content.respond_to? m
  end
  
  def content
    result = @stack.size > 0 ? @stack.last : original
    return result
  end
  
  def subflow wiget, &answer_action
    raise "Subflow component should be Wiget but is '#{wiget.class.name}'" unless wiget.is_a? Wiget
    raise "Can't subflow on empty content!" unless content
    
    @stack << wiget
    @actions << answer_action
    
    refresh
  end
  
  def answer value = nil
    raise "There is no subflow!" unless @stack.size > 0
    
    @stack.pop
    action = @actions.pop
    action.call value if action
    
    refresh
  end    
  
  def cancel
    raise "There is no subflow!" unless @stack.size > 0
    
    @stack.pop
    @actions.pop		
    
    refresh
  end	
end