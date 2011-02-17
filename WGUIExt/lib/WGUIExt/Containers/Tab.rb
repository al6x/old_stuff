class Tab < WComponent
  include Container, Utils::WigetState
  
  attr_accessor :active, :title, :title_css, :wide
  
  children :@content, :@controls
  
  def initialize
    super
    @names, @weights, @wigets, @disabled_tabs = [], [], [], []
    @wide = true
    self.css = "container font input"
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
  
  def dsl_add name, container, parameters = nil, &b
  	name.should! :be_a, String  
  	if container.is_a? Symbol
  		add name, dsl_builder.new(container, parameters, &b)
  	elsif container.is_a? Core::Wiget
  		add name, container
  	else
  		should! :be_never_called
  	end
  end
  
  def dsl_add_wiget wiget, name
  	add name, wiget
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