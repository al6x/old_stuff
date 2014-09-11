class StateMashine
  attr_accessor :object
  
  def initialize object = nil;
    @object = object
    @on_entry, @on_exit, @on_event = {}, {}, {}
    
    @custom_states = {}
    if self.class.custom_state_get
      self.class.custom_state_get.each do |state, klass|
        @custom_states[state] = klass.new
      end    
    end
    
    is = self.class.initial_state_get
    raise_without_self "Initial State not defined!" unless is    
    fire_action @on_entry[is]            
    @state = is
  end
  
  def on_entry state, method = nil, &b
    if method or b
      @on_entry[state] = method || b
    else
      @on_entry.delete state
    end
  end
  
  def on_event from, event, method = nil, &b
    if method or b
      @on_event[from + event] = method || b
    else      
      @on_event.delete from + event
    end
  end  
  
  def on_exit state, method = nil, &b
    if method or b
      @on_exit[state] = method || b
    else
      @on_exit.delete state
    end
  end
  
  def event event        
    custom_state = @custom_states[state]
    
    to = if custom_state
      begin
        custom_state.send event
      rescue NoMethodError
        raise_without_self "There is no :#{event} Event in :#{state} State!"
      end
    else
      actions = self.class.from_actions[state]
      raise_without_self "There is no :#{event} Event in :#{state} State!" unless actions
      actions[event]      
    end
    raise_without_self "There is no :#{event} Event in :#{state} State!" unless to
    
    #    p [state, event, to]
    
    old_state = state
    
    @state = to
    
    begin
      fire_action @on_exit[old_state]
      fire_action @on_event[old_state + event] 
      fire_action @on_entry[to]                      
    rescue Exception => e
      @state = old_state
      raise e
    end
  end    
  
  def state; @state end
  
  def state= new_state
    custom_state = @custom_states[state]
    
    event = if custom_state
      begin
        custom_state.state new_state
      rescue Exception => e
        raise e
      end
    else
      states = self.class.from_states[state]
      raise_without_self "There is no way from :#{state} State into :#{new_state} State!" unless states
      states[new_state]      
    end
    raise_without_self "There is no way from :#{state} State into :#{new_state} State!" unless event
    
    old_state = state
    
    @state = new_state
    
    begin
      fire_action @on_exit[old_state]
      fire_action @on_event[old_state + event] 
      fire_action @on_entry[new_state]        
    rescue Exception => e
      @state = old_state
      raise e
    end
  end
  
  def == other
    return true if equal? other
    return state == other if other.is_a? Symbol
    return state == other.state if other.is_a? StateMashine
    return false
  end
  
  def hash
    state.hash
  end
  
  def eql? other
    return true if equal? other
    return state == other.state if other.is_a? StateMashine
    return false
  end
  
  class << self
    def from_actions; @from_actions end
    def from_states; @from_states end      
    def initial_state_get; @initial_state end    
    def custom_state_get; @custom_state end
    
    def transitions *args
      @from_actions, @from_states = {}, {}
      args.each do |from, action, to|        
        actions = @from_actions[from]
        unless actions
          actions = {}
          @from_actions[from] = actions
        end        
        actions[action] = to
        
        states = @from_states[from]
        unless states
          states = {}
          @from_states[from] = states
        end        
        states[to] = action
      end
    end
    
    def custom_state state, klass; 
      @custom_state ||= {}
      @custom_state[state] = klass
    end
    
    def initial_state state; @initial_state = state end
  end
  
  def to_s
    "#<#{self.class.name} state = :#{state}"
  end
  
  def inspect
    to_s
  end
  
  protected
  def fire_action a
    return unless a
    if a.is_a? Symbol
      @object.send a if @object
    else
      a.call
    end
  end
end