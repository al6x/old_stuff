Object.class_eval do
  unless method_defined? :try
    def try method, *args, &block
      self && self.send(method, *args, &block)
    end
  end
end

class String
  def self.random length = 3
    @digits ||= ('a'..'z').to_a + (0..9).to_a
    (0..(length-1)).map{@digits[rand(@digits.size)]}.join
  end
end