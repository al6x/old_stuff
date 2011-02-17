# content_or_self
[Hash, OpenObject].each do |aclass|
  aclass.class_eval do 
    def hash?; true end
  end
end

NilClass.class_eval do
  def content; "" end
  def hash?; false end
end

String.class_eval do
  def content; self end
  def hash?; false end
end

# OpenObject
OpenObject.class_eval do
  HTML_ATTRIBUTES = [:id, :class]
  
  def merge_html_attributes hash
    # html attributes
    result = {}
    HTML_ATTRIBUTES.each{|k| result[k.to_s] = self[k] if include? k}
    html_attributes.each{|k, v| result[k.to_s] = v} if html_attributes?
    
    # merging html attributes with hash
    hash.each do |k, v|
      k = k.to_s
      if result.include?(k) and v.is_a?(String)
        string = result[k].should! :be_a, [Symbol, String]
        result[k] = "#{result[k]}#{v}"
      else
        result[k] = v
      end
    end
    result
  end
  
  protected
    def method_missing( sym, arg=nil, &blk)
      type = sym.to_s[-1,1]
      key = sym.to_s.sub(/[=?!]$/,'').to_sym
      if type == '='
        define_slot(key,arg)
      elsif type == '!'
        define_slot(key,arg)
        self
      elsif type == '?'
        !self[key].blank?
      else
        self[key]
      end
    end
end