class Tab < WComponent
  include Container, Utils::WigetState
  
  attr_accessor :active, :title
  
  children :@content, :@controls
  
  def initialize
    super
    @names, @weights, @wigets, @disabled_tabs = [], [], [], []
  end
  
  def add name, wiget, weight = 0
  	name.should! :be_a, String
  	wiget.should! :be_a, WGUI::Wiget
  	weight.should! :be_a, Numeric
  	
    @names << name
    @weights << weight
    @wigets << wiget
    refresh 
  end
  
  def active= name
    @active = name
    refresh
  end
  
  def disabled_tabs *names  	
    @disabled_tabs = names
    refresh
  end
  
  def build
    @active = view_state if view_state
    
    @content, @controls = nil, []
    
    @names.sort_by_weight! @weights.clone
    @wigets.sort_by_weight! @weights
    
    @names.each_with_index do |name, index|        
    	next if @disabled_tabs.include? name
      if name == active
        @content = @wigets[index]
        @controls << WLabel.new(name)
      else
        btn = WLinkButton.new name do                    
          self.view_state = name
          self.active = name          
        end
        @controls << btn
      end
    end
  end
end