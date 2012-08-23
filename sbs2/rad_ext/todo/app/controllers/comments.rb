class Comments < Items
  # TODO2
  # allow_get_for :show, :new, :edit

  def show
    require_permission :view, @model
  end

  def new
    require_permission :create_comment
    params.item_id.must_not.be_nil
    @model = Models::Comment.new
  end

  def create
    require_permission :create_comment
    @item = Models::Item.by_param! params.item_id
    @model = Models::Comment.new params.model
    @model.item = @item
    @model.owner = Models::User.current
    if @model.save
      flash.info = t :comment_created
      # render action: :new
    else
      render action: :new
    end
  end

  def edit
    require_permission :update_comment, @model
  end

  def update
    require_permission :update_comment, @model
    if @model.set(params.model).save
      flash.info = t :comment_updated
      # render action: :update
    else
      render action: :edit
    end
  end

  def delete
    require_permission :delete_comment, @model
    @model.delete
    flash.info = t :comment_deleteed
  end
end