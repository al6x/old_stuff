class Note < Item
  available_as_markup :text
  assign :original_text, String, true
  validates_presence_of :text

  # TODO2 search
  # searchable do
  #   text :text, using: :text_as_text, stored: true
  # end
end