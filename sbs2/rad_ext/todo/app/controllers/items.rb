class Items < Controllers::App
  persist_params

  before do |c|
    model = workspace.model
    model ||= Models::Item.by_param workspace.params.id if workspace.params.id?
    c.instance_variable_set '@model', model
  end

  partials do
    show :buttons,      only: [:all, :show]
    show :search,       only: [:all, :show]
    show :tags,         only: [:all, :show]
    show :context_menu, only: :show

    show :comments,     only: :show
  end

  helper Helpers::Kit::ItemHelper

  layout '/kit/layout'

  allow_get_for :redirect, :all
  protect_from_forgery

  allow_get_for :show, :new, :edit, :redirect

  def redirect
    url = rad.router.default_url
    url = build_url(:all) if url == '/' or url.blank?
    redirect_to url
  end

  def show
    respond_to do |f|
      if @model
        require_permission :view, @model

        f.html{@html_title = @model.name}
        f.json{render json: @model}
      else
        f.html{render :not_found}
        f.json{render :not_found}
      end
    end
  end

  def new
    require_permission :create
    @model = model_class.new

    respond_to do |f|
      f.js
      f.json{render json: @model}
    end
  end

  def create
    require_permission :create
    @model = model_class.new params.model

    respond_to do |f|
      if @model.save
        flash.info = t :"#{model_class.alias.underscore}_created"

        f.js{redirect_to(path(@model))}
        f.json{render json: @model}
      else
        f.js{render action: :new}
        f.json{render json: {errors: @model.errors}, status: :failed}
      end
    end
  end

  def edit
    require_permission :update, @model

    respond_to do |f|
      f.js
    end
  end

  def update
    require_permission :update, @model

    respond_to do |f|
      if @model.set(params.model).save
        flash.info = t :"#{model_class.alias.underscore}_updated"

        f.js
        f.json{render :ok}
      else
        f.js{render action: :edit}
        f.json{render json: {errors: @model.errors}, status: :failed}
      end
    end
  end

  def delete
    require_permission :delete, @model
    @model.delete
    flash.info = t :"#{model_class.alias.underscore}_deleteed"

    respond_to do |f|
      f.js{redirect_to(default_path)}
      f.json{render :ok}
    end
  end

  def all
    respond_to do |f|
      @page, @per_page = (params.page || 1).to_i, Models::Item::PER_PAGE

      query = self.class.model_class.where(viewers: {_in: rad.user.major_roles}, dependent: {_exists: false})
      query = query.where tags: {_all: selected_tags} unless selected_tags.empty?
      @models = query.sort([:created_at, -1]).paginate(@page, @per_page).all

      f.html{@html_title = rad.config.title}
      f.json{render json: @models}
    end
  end


  #
  # Viewers and Collaborators
  #
  def viewers
    require_permission :update_access, @model
    remove_roles = (params.remove_roles || '').split("\n")
    add_roles = (params.add_roles || '').split("\n")
    partials.show :context_menu

    remove_roles.each{|role| @model.remove_viewer role}
    add_roles.each{|role| @model.add_viewer role}

    respond_to do |format|
      if @model.save
        flash.info = t :viewers_updated

        format.js{render action: :access} # "models/access"
        format.json{render :ok}
      else
        flash.info = t :failed

        format.js{render action: :access} # "models/access"
        format.json{render :failed}
      end
    end
  end

  def collaborators
    require_permission :update_access, @model
    remove_roles = (params.remove_roles || '').split("\n")
    add_roles = (params.add_roles || '').split("\n")
    partials.show :context_menu

    remove_roles.each{|role| @model.remove_collaborator role}
    add_roles.each{|role| @model.add_collaborator role}

    respond_to do |format|
      if @model.save
        flash.info = t :collaborators_updated

        format.js{render action: :access} # "models/access"
        format.json{render :ok}
      else
        flash.info = t :failed

        format.js{render action: :access} # "models/access"
        format.json{render :failed}
      end
    end
  end


  #
  # Layout
  #
  def layout
    require_permission :update, @model

    @model.layout = params.value

    respond_to do |format|
      if @model.save
        flash.info = t :layout_updated

        format.js{reload_page}
        format.json{render :ok}
      else
        flash.info = t :failed

        format.js{}
        format.json{render :failed}
      end
    end
  end


  #
  # model_class
  #
  def self.model_class
    @model_class ||= "Models::#{self.alias.singularize}".constantize
  end
  def model_class; self.class.model_class end
  helper_method :model_class
end