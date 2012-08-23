class Wigets::FolderItem
  include MongoMapper::Document
  
  key :folder_id, ObjectId
  belongs_to :folder, :class_name => "Wigets::Folder"
  

  # 
  # File
  # 
  include Paperclip

  key :file_file_name, String
  key :file_content_type, String
  key :file_file_size, Integer
  key :file_updated_at, Time

  has_attached_file :file, 
    
    # :default_url => "/images/default_:style_avatar.png",
    # User.new.avatar_url(:small) # => "/images/default_small_avatar.png"
    
    :styles => {:icon => "50x50#", :thumb => "200x200#"}
    
    # :whiny => false

  # validates_attachment_presence :file
  
  
  # 
  # Callback
  # 
  def to_hash
    {
      :id => id.to_s,
      :name => file.original_filename,
      :mime => file.content_type,
      :size => file.size,
      :versions => {
        :original => file.url,
        :icon => file.url(:icon),
        :thumb => file.url(:thumb)
      }
    }
  end

  
  timestamps!
end