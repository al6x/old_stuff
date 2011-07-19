p 'move to kit'

class Items < BagApp

  def container_order    
    collection_name = params.collection || 'items'
    index = params.index.to_i
  
    @container = Item.by_slug! params.id
    require_permission :update, @container
  
    @item = Item.by_slug! params[:item_id]
    if @container.send "update_#{collection_name.singularize}_order", @item, index
      @container.save!    
      flash.info = t :order_updated
    end
  
    render '/items/container_order' #, layout: 'application'
  end


  # 
  # Embedded Items Rendering
  # 
  def prepare_container
    @container = Item.by_slug! params.container_id unless params.container_id.blank?
  end
  before :prepare_container

  def container; @container.must_not_be.blank end
  def standalone?; @container.blank? end
  def embedded?; !standalone? end
  helper_method :embedded?, :standalone?, :container, :set_container

  def set_container container, &block
    before = @container
    begin
      @container = container
      block.call
    ensure
      @container = before
    end
  end
  
  # 
  # Adding items to container
  # 
  def save_and_add_to_container_if_needed item
    if embedded?
      item.dependent!
      item.inherit_container_attributes @container
      if item.save
        require_permission :update, @container

        collection_name = params.collection || 'items'
        @container.send(collection_name) << item

        unless params.index.blank?
          index = params.index.to_i
          @container.send "update_#{collection_name.singularize}_order", item, index
        end
        @container.save!
        
        return true
      else
        return false
      end
    else
      return item.save
    end
  end
  
  
  def add
    @container = Item.by_slug! params.id
    require_permission :update, @container
    
    @item = Item.by_slug! params.item_id
    require_permission :update, @item
    
    collection_name = params.collection || 'items'    
    @container.send(collection_name) << @item
    
    respond_to do |format|
      begin
        unless params.index.blank?
          index = params.index.to_i
          @container.send "update_#{collection_name.singularize}_order", @item, index
        end
        @container.save!      
        
        format.json{render :ok}
      rescue RuntimeError => e
        format.json{render :failed}
      end
    end
  end
end