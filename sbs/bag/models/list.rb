class List < Item  
  contains :items
  add_order_support_for :items
  
  validates_presence_of :name
  
  def item_updated item
    super
    move_finished_item_to_bottom item if item.finished? and item.state_changed?      
  end
  
  protected
    # moves finished task before first non-finished from bottom
    def move_finished_item_to_bottom item
      index = ordered_items.rindex{|task| !task.finished?}
      if index
        update_item_order item, index
        save!
      end
    end
end