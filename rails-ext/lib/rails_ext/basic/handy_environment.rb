module Rails
  class << self
    def development?
      RAILS_ENV == 'development'
    end
    
    def test?
      RAILS_ENV == 'test'
    end
    
    def production?
      RAILS_ENV == 'production'
    end
    
    def development *args, &block
      if development?
        if block 
          block.call
        else
          return *args
        end
      end
    end
    
    def test *args, &block
      if test?
        if block 
          block.call
        else
          return *args
        end
      end
    end
  
    def production *args, &block
      if production?
        if block 
          block.call
        else
          return *args
        end
      end
    end
  end
end