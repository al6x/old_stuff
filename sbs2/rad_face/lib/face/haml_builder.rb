class Rad::Face::HamlBuilder < BasicObject
  def initialize template, hash = {}
    @template = template
    @hash = ::Rad::Face::HtmlOpenObject.initialize_from(hash)
    @array = []
  end

  def method_missing m, value = nil, &block      
    @hash[m] = ::Rad::Face::HamlBuilder.get_input @template, value, &block
    nil
  end

  def add value = nil, &block      
    @array << ::Rad::Face::HamlBuilder.get_input(@template, value, &block)
    nil
  end

  def get_value
    !@array.empty? ? @array : @hash
  end

  def self.get_input template, value, &block
    value = ::Rad::Face::HtmlOpenObject.initialize_from(value) if value.is_a? ::Hash
  
    block_value = if block 
      if block.arity <= 0
        template.must.be_defined
        template.capture &block
      else
        b = ::Rad::Face::HamlBuilder.new template
        block.call b
        b.get_value
      end
    else
      nil
    end
  
    if value and block_value
      if block_value.is_a? ::Hash
        value.merge! block_value
      else
        raise "Invalid usage!" if value.include? :content
        value.content = block_value
      end
    end
  
    value || block_value
  end    
end