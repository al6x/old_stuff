class Rad::Face::HtmlOpenObject < OpenObject
  HTML_ATTRIBUTES = [:id, :class]
  
  def merge_html_attributes hash = {}
    # html attributes
    result = {}
    HTML_ATTRIBUTES.each{|k| result[k.to_s] = self[k] if include? k}
    html_attributes.each{|k, v| result[k.to_s] = v} if html_attributes?
    
    # merging html attributes with hash
    hash.each do |k, v|
      k = k.to_s
      if result.include?(k) and v.is_a?(String)
        string = result[k].must.be_a Symbol, String
        result[k] = "#{result[k]}#{v}"
      else
        result[k] = v
      end
    end
    result
  end
  
  def self.initialize_from hash, deep = false
    unless deep
      ::Rad::Face::HtmlOpenObject.new.update hash 
    else
      r = ::Rad::Face::HtmlOpenObject.new
      hash.each do |k, v|
        r[k] = if v.is_a? Hash
          v.to_openobject
        else
          v
        end
      end
      r
    end
  end
  
  protected
    # should threat newlines as blank
    def method_missing m, arg = nil, &block      
      type = m[-1,1]
      if type == '='
        self[m[0..-2]] = arg
      elsif type == '!'        
        self[m[0..-2]]
      elsif type == '?'        
        value = self[m[0..-2]]
        !(value.is_a?(String) ? (value =~ /\A\s*\z/) : value.blank?)
      else
        self[m]
      end
    end  
end