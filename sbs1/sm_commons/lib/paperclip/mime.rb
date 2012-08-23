MIME::Types.class_eval do
  def self.image? file_name
    !file_name.blank? and type_for(file_name).any?{|t| t.content_type =~ /image/}
  end
end