class Order
  inherit Mongo::Model::Validation
  include RubyExt::OpenConstructor
  
  def valid? options = {}
    run_model_validations && errors.empty?
  end
  
  def initialize options = {}
    super
    set! options
  end
  
  attr_accessor :name
  attr_accessor :phone
  attr_accessor :details
  
  validates_presence_of :name
  validates_presence_of :phone
end