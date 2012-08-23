FileModel.metaclass_eval do
  def box name
    raise 'invalid box name' unless name == :default

    config = rad.models.fs
    driver_class = config['driver_class'] || raise("driver for FileModel not defined!")
    _class = eval driver_class, TOPLEVEL_BINDING, __FILE__, __LINE__
    options = config['options'] || {}
    driver = _class.new options
    Vos::Box.new driver
  end
  cache_method_with_params :box
end