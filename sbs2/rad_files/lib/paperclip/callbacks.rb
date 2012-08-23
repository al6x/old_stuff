Paperclip::ClassMethods.class_eval do
  def trace_file attachment    
    upd_method_name = "update_file_size_for_#{attachment}".to_sym
    define_method upd_method_name do
      return if disable_file_audit?

      size = file_size_for(attachment) 
      old_size = old_file_size_for(attachment)      

      if (difference = size - old_size) != 0
        self.class.increase_user_and_account_files_size difference
        set_old_file_size_for(attachment, size)
      end
    end
    protected upd_method_name
    before_save upd_method_name
    
    clear_method_name = "clear_file_size_for_#{attachment}".to_sym
    define_method clear_method_name do            
      return if disable_file_audit?

      difference = - old_file_size_for(attachment)
      self.class.increase_user_and_account_files_size difference
    end
    protected clear_method_name
    after_destroy clear_method_name
  end
  
  def increase_user_and_account_files_size difference    
    # Upsert can't be used becouse user.files_size is not just an attribute
    # User.current.files_size += difference    
    # User.upsert :$inc => {files_size: difference}
    u = Models::User.current
    u.files_size += difference
    u.save!
    
    Account.current.files_size += difference
    Account.current.upsert! :$inc => {files_size: difference}
  end
end