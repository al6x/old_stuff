class Models::Tag
  inherit Mongo::Model
  collection :tags

  rad.extension :tag_model, self do
    create_index [[:name, 1]], unique: true
  end

  FORBIDDEN_CHARACTERS = /<>,/
  TAG_LIST_DELIMITER = ','

  attr_accessor :name, :count
  assign :name, String, true
  validates_presence_of :name, :count
  validate :validate_name

  attr_reader :context
  def context
    if name.to_s =~ /:/
      @context = name.split(/:/).first
    else
      remove_instance_variable :@context if instance_variable_defined? :@context
      nil
    end
  end
  before_save :context

  def update_count!
    new_count = Models::Item.count tags: {_in: [name]}
    unless count == new_count
      self.count = new_count
      self.save!
    end
  end

  class << self
    def valid_name? name
      name.present? and name !~ FORBIDDEN_CHARACTERS
    end

    def create_tags! tags
      tags.each do |name|
        tag = Models::Tag.new name: name
        tag.count = 1
        unless tag.save
          # There's already such tag, increasing count.
          Models::Tag.update({name: name}, _inc: {count: 1})
        end
      end
    end

    def update_tags! before, after
      create_tags! after - before
      delete_tags! before - after
    end

    def delete_tags! tags
      if tags.size > 0
        Models::Tag.update({name: {_in: tags}}, _inc: {count: -1})
        Models::Tag.delete_all count: {_lte: 0}
      end
    end
  end

  protected
    def validate_name
      errors.add :name, t(:invalid_tag_name) unless Models::Tag.valid_name?(name)
    end
end