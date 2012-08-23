class Models::Comment < Models::Item
  attr_accessor :item_id
  validates_presence_of :item_id
  def item= item
    self.item_id = item._id
    _cache[:item] = item
  end
  def item
    _cache[:item] ||= Item.by_id item_id
  end

  after_create do |m|
    Item.update({_id: m.item_id}, {_inc: {comments_count: 1}})
  end
  after_delete do |m|
    Item.update({_id: m.item_id}, {_inc: {comments_count: -1}})
  end

  available_as_markup :text
  assign :original_text, String, true
  validates_presence_of :text

  before_save{|m| m.dependent!}

  # TODO3 search.
  # searchable do
  #   text :text, using: :text_as_text
  # end
end