class Pages < Items
  prepare_model Page, finder: :by_slug!, only: %w(edit update destroy)
  
  # def index
  #   render inline: 'outdated'
  #   return
  #   
  #   page = params[:page] || 1
  #   @pages = Page.tagged_with(selected_tags, visibility: User.current.major_roles, page: page)
  #   
  #   respond_to do |format|
  #     format.html
  #     format.json{render json: @pages}
  #   end
  # end
  
  def show
    @page = Page.by_slug params.id
    respond_to do |format|
      if @page
        require_permission :view, @page
        format.html{@html_title = @page.name}
        format.json{render json: @page}
      else
        format.html{render :not_found}
        format.json{render :not_found}
      end
    end
  end
  
  def new
    require_permission :create
    @page = Page.new
    
    respond_to do |f|
      f.js{old_render_action :new}
      f.json{render json: @page}
    end
  end
  
  def create
    require_permission :create
    @page = Page.new params.page
    
    respond_to do |f|
      if save_and_add_to_container_if_needed @page
        flash.info = t :page_created
        
        f.js{standalone? ? redirect_to(show_page_path(@page)) : old_render_action(:update)}
        f.json{render json: @page}
      else
        f.js{old_render_action :new}        
        f.json{render json: {errors: @page.errors}, status: :failed}
      end
    end
  end
  
  def edit
    require_permission :update, @page
    
    respond_to do |f|
      f.js{old_render_action :edit}
    end
  end
  
  def update
    require_permission :update, @page
    
    respond_to do |f|
      if @page.update_attributes params.page
        flash.info = t :page_updated
        
        f.js{old_render_action :update}
        f.json{render :ok}
      else
        f.js{old_render_action :edit}
        f.json{render json: {errors: @page.errors}, status: :failed}
      end
    end
  end
  
  def destroy    
    require_permission :destroy, @page
    @page.destroy
    flash.info = t :page_deleted
    
    respond_to do |f|
      f.js{standalone? ? redirect_to(default_path) : old_render_action(:destroy)}
      f.json{render :ok}
    end
  end
end