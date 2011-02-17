Paperclip.class_eval do
  def self.registered_classes
    @registered_classes ||= Hash.new{|h, k| h[k] = []}
  end 
end

Paperclip::ClassMethods.class_eval do  
  def has_attached_file name, options = {}
    name = name.to_s
    
    Paperclip.registered_classes[self.collection.name] << name
    
    define_paperclip_keys_for name
    
    include Paperclip::InstanceMethods

    write_inheritable_attribute(:attachment_definitions, {}) if attachment_definitions.nil?
    attachment_definitions[name] = {:validations => []}.merge(options)

    after_save :save_attached_files
    before_destroy :destroy_attached_files

    define_callbacks :before_post_process, :after_post_process
    define_callbacks :"before_#{name}_post_process", :"after_#{name}_post_process"
   
    define_method name do |*args|
      a = attachment_for(name)
      (args.length > 0) ? a.to_s(args.first) : a
    end

    define_method "#{name}=" do |file|
      attachment_for(name).assign(file)
    end

    define_method "#{name}?" do
      attachment_for(name).file?
    end

    validates_each name, :logic => lambda {
      attachment = attachment_for(name)
      attachment.send(:flush_errors) unless attachment.valid?
    }
  end
  
  def disable_file_audit &block
    begin
      Thread.current['disable_file_audit'] = true
      block.call
    ensure
      Thread.current['disable_file_audit'] = nil
    end
  end
  
  def enable_file_audit &block
    begin
      Thread.current['disable_file_audit'] = false
      block.call
    ensure
      Thread.current['disable_file_audit'] = nil
    end
  end
  
  protected
    def define_paperclip_keys_for attachment
      key "#{attachment}_file_name", String
      key "#{attachment}_content_type", String
      key "#{attachment}_file_size", Integer
      key "#{attachment}_updated_at", Time    
      
      key "#{attachment}_old_file_size"
    end    
end

Paperclip::InstanceMethods.class_eval do
  protected
    def disable_file_audit?
      disable = Thread.current['disable_file_audit']
      if disable != nil
        disable
      else
         Rails.test?
      end
    end
    
    def file_size_for attachment
      send("#{attachment}_file_size") || 0
    end
  
    def old_file_size_for attachment
      send("#{attachment}_old_file_size") || 0
    end  
    
    def set_old_file_size_for attachment, size
      send("#{attachment}_old_file_size=", size)
    end
end

Paperclip::Interpolations.class_eval do
  # fix filename to works with files without extension
  def filename attachment, style      
    unless (ext = extension(attachment, style)).blank?
      "#{basename(attachment, style)}.#{ext}"
    else
      basename(attachment, style)
    end
  end
end

Paperclip::Attachment.class_eval do
  # allow spaces in filename
  def assign uploaded_file
    ensure_required_accessors!
  
    if uploaded_file.is_a?(Paperclip::Attachment)
      uploaded_file = uploaded_file.to_file(:original)
      close_uploaded_file = uploaded_file.respond_to?(:close)
    end
  
    return nil unless valid_assignment?(uploaded_file)
  
    uploaded_file.binmode if uploaded_file.respond_to? :binmode
    self.clear
  
    return nil if uploaded_file.nil?
  
    @queued_for_write[:original]   = uploaded_file.to_tempfile
    instance_write(:file_name,       uploaded_file.original_filename.strip.gsub(/[^A-Za-z\d\.\-_ ]+/, '_'))
    instance_write(:content_type,    uploaded_file.content_type.to_s.strip)
    instance_write(:file_size,       uploaded_file.size.to_i)
    instance_write(:updated_at,      Time.now)
  
    @dirty = true
  
    post_process if valid?
  
    # Reset the file size if the original file was reprocessed.
    instance_write(:file_size, @queued_for_write[:original].size.to_i)
  ensure
    uploaded_file.close if close_uploaded_file
    validate
  end
  
  alias_method :file_name, :original_filename
  
  def blank?; file_name.blank? end  
  
  # returns nil if file_name is blank
  def url_with_default *args
    unless file_name.nil?
      url_without_default *args
    else
      nil
    end
  end
  alias_method_chain :url, :default  

  # Hack to use styles with no processors
  def post_process_styles_with_blank
    @styles.each do |name, args|
      return if args[:processors].blank?
    end
    post_process_styles_without_blank
  end
  alias_method_chain :post_process_styles, :blank
end