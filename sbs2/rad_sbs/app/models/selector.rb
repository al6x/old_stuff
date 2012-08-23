class Selector < Item
  VIEWS = %w{line thumb}

  attr_writer :query
  def query; @query ||= [] end
  available_as_string :query, :line
  assign :query_as_string, String, true


  attr_writer :view
  def view; @view ||= 'line' end
  assign :view, String, true
  validates_presence_of :view
  validates_inclusion_of :view, in: VIEWS


  available_as_markup :text
  assign :original_text, String, true

  def items; @_items ||= [] end
  def items= items; @_items = items end

  # TODO1 update this
  def to_json options = {}
    super options.merge(methods: [:items])
  end

  # TODO2 search
  # searchable do
  #   text :text, using: :text_as_text
  # end
end