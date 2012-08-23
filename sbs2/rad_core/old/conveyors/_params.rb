class Rad::Conveyors::Params < OpenObject
  def initialize h = nil
    update h if h
  end

  def inspect
    to_hash.inspect
  end

  def get_data
    data = clone
    data.delete :format
    data
  end
end