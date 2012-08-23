Rad::Controller::Abstract::ClassMethods.class_eval do
  def prepare_model aclass, opt = {}
    opt = opt.symbolize_keys
    id = opt.delete(:id) || :id    
    variable = opt.delete(:variable) || aclass.alias.underscore
    
    finder = opt.delete(:finder) || :find!
    
    method = "prepare_#{variable}"
    define_method method do
      model = aclass.send finder, params[id]
      instance_variable_set "@#{variable}", model
    end
    before method, opt
  end
end