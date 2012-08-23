class Folders < Items
  # prepare_model Folder, finder: :by_slug!, only: %w(edit update destroy) #, :refresh, :refresh_file]
  
  def show
    # @folder = Folder.by_slug params.id
    
    respond_to do |f|
      if @folder
        require_permission :view, @folder
        
        f.html{@html_title = @folder.name}
        f.json{render json: @folder}
      else
        f.html{render :not_found}
        f.json{render :not_found}
      end
    end
  end

  def new
    require_permission :create
    @folder = Folder.new
    
    respond_to do |f|
      f.js{old_render_action :new}
      f.json{render json: @folder}
    end
  end
  
  def create
    require_permission :create
    @folder = Folder.new params.folder
    
    respond_to do |f|
      if save_and_add_to_container_if_needed @folder
        flash.info = t :folder_created
        
        f.js{standalone? ? redirect_to(path(@folder)) : old_render_action(:update)}
        f.json{render json: @folder}
      else
        f.js{old_render_action :new, :edit}        
        f.json{render json: {errors: @folder.errors}, status: :failed}
      end
    end
  end
  
  def edit
    require_permission :update, @folder
    
    respond_to do |f|
      f.js{old_render_action :edit}
    end
  end
  
  def update
    require_permission :update, @folder
    
    respond_to do |f|
      if @folder.update_attributes params.folder
        flash.info = t :folder_updated
        
        f.js{old_render_action :update}
        f.json{render :ok}
      else
        f.js{old_render_action :edit}
        f.json{render json: {errors: @folder.errors}, status: :failed}
      end
    end
  end
  
  def destroy    
    require_permission :destroy, @folder
    @folder.destroy
    flash.info = t :folder_destroyed
    
    respond_to do |f|
      f.js{standalone? ? redirect_to(default_path) : old_render_action(:destroy)}
      f.json{render :ok}
    end
  end
end