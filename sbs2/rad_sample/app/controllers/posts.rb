class Posts < Nodes
  def destroy_old
    @models = model_class.where(skip: rad.blog.collection_limit).destroy_all
    flash.info t(:old_posts_destroyed)
    reload_page
  end
end