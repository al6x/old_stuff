class Page < Item  
  # validates_presence_of :name
  
  contains :items
  add_order_support_for :items  
  
  markup_key :text
  

  # TODO2 fix it  
  # searchable do
  #   text :text, using: :text_as_text
  # end
end