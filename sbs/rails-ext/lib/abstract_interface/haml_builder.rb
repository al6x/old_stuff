module AbstractInterface
  class HamlBuilder < BlankSlate
    def initialize template, hash = OpenObject.new
      @template = template
      @hash, @array = hash, []
    end
    
    def method_missing m, value = nil, &block      
      @hash[m] = HamlBuilder.get_input @template, value, &block
      nil
    end
  
    def add value = nil, &block      
      @array << HamlBuilder.get_input(@template, value, &block)
      nil
    end
    
    # def add_item content, opt = {}, &block
    #   opt[:content] = content
    #   opt[:content] ||= @template.capture &block if block
    #   add opt
    # end
      
    def get_value
      !@array.empty? ? @array : @hash
    end
    
    def self.get_input template, value, &block
      value = value.is_a?(Hash) ? value.to_openobject : value
      
      block_value = if block 
        if block.arity <= 0
          template.should_not! :be_nil
          template.capture &block
        else
          b = HamlBuilder.new template
          block.call b
          b.get_value
        end
      else
        nil
      end
      
      if value and block_value
        if block_value.is_a? Hash
          value = value.merge block_value
        else
          raise "Invalid usage!" if value.include? :content
          value.content = block_value
        end
      end
      
      value || block_value
    end    
  end
end