class Rad::Conveyors::Processor
  inject :workspace, :logger

  attr_accessor :next_processor

  def initialize next_processor
    @next_processor = next_processor
  end

  def self.inspect
    self.name.split('::').last
  end
end