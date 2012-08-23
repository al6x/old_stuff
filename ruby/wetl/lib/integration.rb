Nokogiri::XML::Node.class_eval do
  def inner_html_in_utf
    inner_html(:encoding => 'UTF-8')
  end
end

String.class_eval do
  def strong_escape
    gsub(/[^a-zA-Z0-9_]/, '-')
  end
  
  def dump_to_file fname
    File.open(fname, 'w'){|f| f.write self}       
  end
end