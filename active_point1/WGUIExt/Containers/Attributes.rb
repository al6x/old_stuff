class Attributes < WComponent
  include Container
  
  attr_accessor :title, :metadata
  attr_reader :editors, :labels
  
  children :editors
  
  def initialize
    super
    @labels = []
    @editors = []
    @weights = []
  end  
  
  def add label, editors, weight = 0
  	label.should! :be_a, [NilClass, String]
  	editors.should! :be_a, [Array, WGUI::Wiget]
  	weight.should! :be_a, Numeric
  	
    if label.is_a? Symbol 
      label = Attributes.label_resolver.call metadata, label if Attributes.label_resolver
    end
    labels << label
    self.editors << (editors.is_a?(Array) ? editors : [editors])		
    @weights << weight   
    refresh
  end
  
  def build		
    labels.sort_by_weight! @weights
    editors.sort_by_weight! @weights
  end		
  
  class << self
    attr_accessor :label_resolver
  end
end