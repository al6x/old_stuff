class Models::Item
  inherit Mongo::Model
  collection :items

  rad.extension :item_model, self

  # General Attributes.

  attr_accessor :name, :text
  assign do
    name String, true
    text String, true
  end

  timestamps!

  # Comments.
  # TODO2 add support for security inheritance for comments.
  def comments
    Comment.query({item_id: _id}, {sort: [[:created_at, -1]]})
  end
  after_delete{|m| m.comments.each(&:delete!)}

  attr_writer :comments_count
  def comments_count; @comments_count ||= 0 end

  # Aspects.
  inherit Models::TagsMixin, Models::Authorization::ObjectHelper, Models::TextProcessor

  # Teaser.

  TEASER_LENGTH = 350
  def teaser
    generate_teaser! unless @teaser
    @teaser
  end
  attr_writer :teaser

  def generate_teaser!
    self.teaser = TextUtils.truncate text, TEASER_LENGTH if text # if new_record? or teaser_changed?
  end
  before_save :generate_teaser!

  # TODO3 search
  # include Sunspot::MongoMapper::Searchable
  # searchable do
  #   text :name, stored: true, boost: 2.0
  #   text :teaser, stored: true
  #
  #   string :tags, multiple: true
  #   string :dependent
  #   # string :model_name
  #   string :viewers, multiple: true
  #   time :created_at
  #   time :updated_at
  #
  #   string(:space_id){space_id.to_s}
  #   string(:account_id){account_id.to_s}
  # end

  # Visual layout.
  attr_accessor :layout
  assign :layout, String, true

  # Miscellaneous.

  def to_param; slug end

  PER_PAGE = 14

  # TODO2 refactor with model profiles.
  ALLOWED_KEYS = %w(
    id _type slug
    name text tags dependent
    owner_name viewers
    created_at updated_at
  )
  def to_json options = {}
    options[:only] = ((options[:only] || []) + ALLOWED_KEYS).uniq

    # TODO3 files
    # options[:methods] = ((options[:methods] || []) + [:icon_url]).uniq

    super options
  end
end

# Aspects.
Dir.glob("#{__FILE__.dirname}/item/_*.rb").each{|path| load path}