module Controllers::PrepareModel
  module ClassMethods
    def prepare_model model_class, opt = {}
      id       = opt.delete(:id)       || :id
      variable = opt.delete(:variable) || model_class.alias.underscore
      finder   = opt.delete(:finder)   || :by_id!

      method = :"prepare_#{variable}"
      define_method method do
        model = model_class.send finder, params[id]
        instance_variable_set "@#{variable}", model
      end
      before method, opt
    end
  end
end