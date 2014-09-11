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
  
  def content
    @stack.size > 0 ? @stack.last : original
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