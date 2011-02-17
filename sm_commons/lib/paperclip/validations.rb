Paperclip::ClassMethods.class_eval do
  
  def validates_file attachment
    validates_maximum_file_size attachment
    validates_maximum_user_files_size attachment
    validates_maximum_account_files_size attachment
  end
  
  def validates_maximum_file_size attachment
    method_name = "validates_maximum_#{attachment}_size"
    define_method method_name do
      max_size = Account.current? ? Account.current.max_file_size : SETTING.max_file_size!
      size = file_size_for(attachment)            
      errors.add attachment, t(:invalid_file_size, :max_size => (max_size / 1000)) if size > max_size
    end    
    protected method_name
    validate method_name
  end
  
  def validates_maximum_user_files_size attachment
    method_name = "validates_maximum_user_files_size_for_#{attachment}"
    define_method method_name do
      return if disable_file_audit?
      max_files_size = Space.current.max_user_files_size        
      return if max_files_size == 0
      
      files_size = User.current.files_size      
      size = file_size_for(attachment)
      old_size = old_file_size_for(attachment)
      if size + files_size > max_files_size - old_size
        errors.add(attachment, t(
          :maximum_user_files_size_exceeded, 
          :max_files_size => (max_files_size / 1000), 
          :files_size => (files_size / 1000)
        )) 
      end
    end    
    protected method_name
    validate method_name
  end
  
  def validates_maximum_account_files_size attachment
    method_name = "validates_maximum_account_files_size_for_#{attachment}"
    define_method method_name do
      return if disable_file_audit?
      
      files_size = Account.current.files_size
      max_files_size = Account.current.max_account_files_size        
      size = file_size_for(attachment)
      old_size = old_file_size_for(attachment)
      if size + files_size > max_files_size - old_size
        errors.add(attachment, t(
          :maximum_account_files_size_exceeded, 
          :max_files_size => (max_files_size / 1000), 
          :files_size => (files_size / 1000)
        )) 
      end
    end    
    protected method_name
    validate method_name
  end
end