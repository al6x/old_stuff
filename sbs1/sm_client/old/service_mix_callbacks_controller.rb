class ServiceMixCallbacksController < ActionController::Base
  acts_as_wiget_callback
  before_filter :prepare_resource

  def update_rating
    begin 
      rating = params[:rating].should_not_be!(:blank)
      if @resource.respond_to? :rating
        @resource.rating = rating 
        @resource.save!
      end
      render :json => {}
    rescue RuntimeError => e
      raise_user_error "Internal Error in update_rating"
    end
  end
  
  def update_comments
    begin 
      comments_count = params[:comments_count].should_not_be!(:blank)
      if @resource.respond_to? :comments_count
        @resource.comments_count = comments_count
        @resource.save!
      end
      render :json => {}
    rescue RuntimeError => e
      raise_user_error "Internal Error in update_comments"
    end
  end  
  
  def update_files
    begin 
      if @resource.respond_to? :files
        files_params = JSON.parse params[:files]
        
        new_names = files_params.collect{|data| data['name']}
        existed_names = @resource.files.collect &:name
        
        to_add = new_names - existed_names
        to_delete = existed_names - new_names
        
        RemoteFile.transaction do
          to_add.each do |name|
            params = files_params.find{|data| data['name'] == name}
            RemoteFile.create! params.merge(:resource => @resource)
          end
          
          to_delete.each do |name|
            @resource.files.find_by_name(name).destroy
          end
        end
      end
      render :json => {}
    rescue RuntimeError => e
      raise_user_error "Internal Error in update_comments"
    end
  end
  
  protected
  
    
end