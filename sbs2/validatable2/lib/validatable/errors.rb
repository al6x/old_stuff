module Validatable
  class Errors < Hash
    def initialize
      super([])
    end

    def add attribute, message
      attribute = attribute.to_sym
      self[attribute] = [] unless self.include? attribute
      self[attribute].push *Array(message)
    end
  end
end