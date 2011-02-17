module Samples
  class Errors < OpenObject
    def on key
      self[key]
    end
  end
  
  class ThemeSample < OpenObject

  end
  
  def self.build_stub!
    s = ThemeSample.new :name => "Some Name", :active => true, :body => "Some text"
    s.errors = Errors.new \
      :base => ["Base Error Description", "Base Error Description 2"],
  	  :name => ["Name Error Description 1", "Name Error Description 2"]
    s
  end
  
end