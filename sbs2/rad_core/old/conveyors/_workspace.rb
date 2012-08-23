class Rad::Conveyors::Workspace < OpenObject
  def params
    self[:params] || ::Rad::Conveyors::Params.new
  end

  def params?
    !!params
  end

  alias_method :set_without_params, :[]=
  def []= k, v
    if k.to_s == 'params'
      self.params = v
    else
      set_without_params k, v
    end
  end

  def params= v
    if v.is_a? ::Rad::Conveyors::Params
      set_without_params :params, v
    else
      set_without_params :params, ::Rad::Conveyors::Params.new(v)
    end
  end

  def inspect
    h = {}
    each{|k, v| h[k] = v}
    h['env'] = "..." if h.include? 'env'
    h['request'] = "..." if h.include? 'request'
    h.inspect
  end
end