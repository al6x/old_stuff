class Models::Tags < Array
  inherit Mongo::Model

  def initialize array = nil
    super()
    replace array if array
  end

  # Working with context

  class ContextTags < Array
    def as_string; join(", ") end
  end

  def topic
    get_tags{|tag| tag !~ /:/}
  end
  def topic= value
    set_tags(value){|tag| tag !~ /:/}
  end

  def as_string; join(", ") end

  # Updating Tag and count cache.

  save_changes = -> tags do
    original_tags = (tags._parent && tags._parent.original.try(:tags)) || Models::Tags.new
    tags._changes = [original_tags, tags]
  end

  attr_accessor :_changes
  before_save   save_changes
  before_delete save_changes

  after_save   do |tags|
    Models::Tag.update_tags! *tags._changes
  end
  after_delete do |tags|
    original_tags, tags = *tags._changes
    Models::Tag.delete_tags! original_tags
  end

  def inspect
    to_a.inspect
  end

  protected
    def validate_tag_names
      errors.add :base, t(:invalid_tags) unless all?{|tag| Models::Tag.valid_name?(tag)}
    end
    validate :validate_tag_names

    def method_missing m, *args, &b
      if m !~ /=$/
        context = m.to_s
        args.size.must == 0
        get_tags{|tag| tag =~ /#{context}:/}
      else
        context = m.to_s[0..-2]
        args.size.must == 1
        value = args.first
        set_tags(value){|tag| tag =~ /#{context}:/}
      end
    end

    def set_tags value, &selector
      new_tags = if value.is_a? String
        value.split(Models::Tag::TAG_LIST_DELIMITER).collect{|name| name.strip}.sort
      else
        value.must.be_a Array
      end
      new_tags.select!(&selector)

      reject!(&selector)
      new_tags.each{|tag| push tag}
      sort!
    end

    def get_tags &selector
      ContextTags.new select(&selector)
    end
end