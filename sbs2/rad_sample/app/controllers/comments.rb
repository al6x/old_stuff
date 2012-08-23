class Comments < Nodes  
  def create
    @node = Models::Node.by_param! params.node_id
    @model = Models::Comment.new params.model
    @model.node = @node
    if @model.save
      flash.info = t :comment_created
    else
      render action: :new
    end
  end
  
  def destroy
    @model.destroy
    flash.info = t :comment_destroyed
  end
end