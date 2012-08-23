class IFile < Item
  model_name 'File'
  
  # 
  # File
  # 
  STYLES = {icon: "50x50#", thumb: "150x150#"}
  
  MIME_ICONS_PATH = "/bag/static/images/mime"
  
  interpolation = "/fs/:account/:space/files/:slug/:filename_with_style"
    
  has_attached_file :file, 
    styles: STYLES,
    url: (config.url_root! + interpolation),
    path: (":public_path" + interpolation),
    processors: lambda{|f| (!f.file.blank? and Mime.image?(f.file.file_name)) ? [:thumbnail] : []}  
  validates_file :file
  trace_file :file
    
  def smart_url style = 'original'
    if Mime.image?(file.file_name) or style == 'original'
      file.url style
    else
      extension = File.extname(file.file_name).sub('.', '')
      self.class.mime_icon_url extension, style
    end
  end

  def file_with_name= file
    self.file_without_name= file
    self.name = self.file.file_name
  end
  alias_method_chain :file=, :name

  def generate_slug    
    if name.blank?
      basename, extname = "", ""
    else
      extname = File.extname name
      basename = File.basename name, extname
    end
    "#{basename.to_url[0..50]}-#{String.random}" # UUIDTools::UUID.random_create.hexdigest[0,6]
  end
    
  def self.mime_icon_url extension, style    
    if !extension.blank? and File.exist?("#{config.public_path!}#{MIME_ICONS_PATH}/#{extension}_#{style}.png")
      MIME_ICONS_PATH + "/#{extension}_#{style}.png"
    else
      MIME_ICONS_PATH + "/dat_#{style}.png"
    end
  end
  DeclarativeCache.cache_method_with_params self.singleton_class, :mime_icon_url
  
  
  # 
  # Audit
  # 
  # before_save
end