class Rad::Conveyors
  def initialize
    @hash = {}
  end

  def [] conveyor_name
    @hash[conveyor_name.to_s] ||= Conveyor.new
  end

  def size; @hash.size end

  def method_missing m, &block
    if block
      block.call self[m]
    else
      self[m]
    end
  end
end