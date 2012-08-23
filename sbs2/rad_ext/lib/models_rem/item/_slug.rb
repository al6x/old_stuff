class Models::Item
  attr_writer :slug
  def slug
    @slug ||= generate_slug
  end
  before_create :slug
  assign :slug, String, true

  rad.extension :item_slug, self do
    create_index [[:slug, 1]], unique: true
  end

  validates_format_of :slug, with: /^[0-9a-z\-]+$/
  validates_presence_of :slug

  def self.by_param! param
    by_param(param) || raise(Mongo::NotFound, "object with slug #{param} not found!")
  end

  def self.by_param param
    self.by_slug(param) || (BSON::ObjectId.legal?(param) && self.by_id(param))
  end



  protected
    def generate_slug
      v = if name.blank?
        String.random(6)
      else
        "#{name.downcase.gsub(/[^a-z0-9-]/, '')[0..50]}-#{String.random}"
      end
    end
end