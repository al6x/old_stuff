class Wigets::Folder
  Folder = Wigets::Folder
  FolderItem = Wigets::FolderItem
  
  include MongoMapper::Document
  include Paperclip
  
  key :folder_type, String
  key :folder_id, String
  
  has_many :items, :class_name => "Wigets::FolderItem", :dependent => :destroy, :foreign_key => :folder_id
  
  timestamps!
  
  def self.find_by_params params
    find_by_folder_type_and_folder_id \
      params['folder_type'].should_not_be!(:blank), 
      params['folder_id'].should_not_be!(:blank)
  end
  
  def to_hash
    {
      :id => id.to_s,
      :folder_type => folder_type,
      :folder_id => folder_id,
      :items => items.collect(&:to_hash)
    }
  end
  
  class << self
    def create_item! params, json_params, secure_params
      folder_params = secure_params[:folder].should_not_be!(:blank)
      folder = Folder.find_by_params(folder_params) || Folder.new(folder_params)

      # can_edit = self.can_edit?([resource])[0]
      # raise_user_error can_edit[:error] unless can_edit[:result] == true
    
      item_params = params[:item].should_not_be!(:blank)
      item = FolderItem.new item_params.merge(:folder => folder)

      if item.save
        # callback! resource.files
      else
        raise_user_error item.errors.full_messages.join(', ')
      end
      
      return item
    end
  end
end