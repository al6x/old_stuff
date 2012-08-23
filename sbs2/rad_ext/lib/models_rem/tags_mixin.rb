module Models::TagsMixin
  def tags; @tags ||= Models::Tags.new end
  def tags= tags
    @tags = Models::Tags.new tags
    @tags._parent = self
    @tags
  end

  def topics_as_string= value
    tags.topic = value
  end
  def topics_as_string
    tags.topic.as_string
  end

  inherited do
    embedded :tags

    before_validate :add_class_to_tags
    validate :validate_class_in_tags
    after_validate :copy_errors_from_tags
    after_build :build_tags

    assign :topics_as_string, String, true
  end

  protected
    def add_class_to_tags
      cname = "_class:#{self.class.name}"
      tags.push(cname).sort! unless tags.include? cname
    end

    def validate_class_in_tags
      cname = "_class:#{self.class.name}"
      errors.add :base, "no class in tags!" unless tags.include? cname
    end

    def copy_errors_from_tags
      errors[:base] = tags.errors[:base] unless tags.errors.empty?
    end

    def build_tags
      self.tags = tags
    end
end