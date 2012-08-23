class Files < Items
  self.item_model = IFile
  # prepare_model IFile, variable: :file, finder: :by_slug!, only: %w(edit update state destroy)

  def show
    # 
    # render inline: request.params.inspect
    # @file = IFile.by_slug params.id
    respond_to do |f|
      if @file
        require_permission :view, @file
        
        f.html{@html_title = @file.name}
        f.json{render json: @file}
      else
        f.html{render :not_found}
        f.json{render :not_found}
      end
    end
  end
  
  def new
    require_permission :create
    @file = IFile.new
    
    respond_to do |f|
      f.js{old_render_action :new}
      f.json{render json: @file}
    end
  end
  
  def create    
    require_permission :create
    @file = IFile.new params.file
    
    respond_to do |f|
      if save_and_add_to_container_if_needed @file
        flash.info = t :file_created        
        f.js{standalone? ? redirect_to(path(@file)) : old_render_action(:create)}
        f.json{render json: @file}
      else
        f.js{old_render_action :new, :edit}
        f.json{render json: {errors: @file.errors}, status: :failed}
      end
    end
  end
  
  def bunch_new
    require_permission :create
    @file = IFile.new
  end
  
  def bunch_create
    require_permission :create
    @file = IFile.new params.file
    
    if save_and_add_to_container_if_needed @file
      flash.info = t :file_created
    else
      flash.error = t :failed
    end
  end  
  
  def edit
    require_permission :update, @file
    
    respond_to do |f|
      f.js{old_render_action :edit}
    end
  end
    
  def update
    require_permission :update, @file
    
    respond_to do |f|
      if @file.update_attributes params.file
        flash.info = t :file_updated
        
        f.js{old_render_action :update}
        f.json{render :ok}
      else
        f.js{old_render_action :edit}
        f.json{render json: {errors: @file.errors}, status: :failed}
      end
    end
  end
  
  def destroy    
    require_permission :destroy, @file
    @file.destroy
    flash.info = t :file_destroyed
    
    respond_to do |f|
      f.js{standalone? ? redirect_to(default_path) : old_render_action(:destroy)}
      f.json{render :ok}
    end
  end
end