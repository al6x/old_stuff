class Product < Item
  validates_presence_of :name

  available_as_markup :text
  assign :original_text, String, true
  validates_presence_of :text

  attr_writer :price
  def price; @price ||= 0 end

  def price_with_currency
    "#{price} #{rad.store.currency}"
  end
end