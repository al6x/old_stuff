class Lists < Items
  prepare_model List, finder: :by_slug!, only: %w(edit update destroy)
  
  def show
    @list = List.by_slug params.id
    respond_to do |f|
      if @list
        require_permission :view, @list
        
        f.html{@html_title = @list.name}
        f.json{render json: @list}
      else
        f.html{render :not_found}
        f.json{render :not_found}
      end
    end
  end
  
  def new
    require_permission :create
    @list = List.new
    
    respond_to do |f|
      f.js{old_render_action :new}
      f.json{render json: @list}
    end
  end
  
  def create
    require_permission :create
    @list = List.new params.list
    
    respond_to do |f|
      if save_and_add_to_container_if_needed @list
        flash.info = t :list_created
        
        f.js{standalone? ? redirect_to(show_list_path(@list)) : old_render_action(:update)}
        f.json{render json: @list}
      else
        f.js{old_render_action :new, :edit}        
        f.json{render json: {errors: @list.errors}, status: :failed}
      end
    end
  end
  
  def edit
    require_permission :update, @list
    
    respond_to do |f|
      f.js{old_render_action :edit}
    end
  end
  
  def update
    require_permission :update, @list
    
    respond_to do |f|
      if @list.update_attributes params.list
        flash.info = t :list_updated
        
        f.js{old_render_action :update}
        f.json{render :ok}
      else
        f.js{old_render_action :edit}
        f.json{render json: {errors: @list.errors}, status: :failed}
      end
    end
  end

  def destroy    
    require_permission :destroy, @list
    @list.destroy
    flash.info = t :list_deleted
    
    respond_to do |f|
      f.js{standalone? ? redirect_to(default_path) : old_render_action(:destroy)}
      f.json{render :ok}
    end
  end
end