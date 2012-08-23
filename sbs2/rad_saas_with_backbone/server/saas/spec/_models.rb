Models::User.class_eval do
  def self.anonymous
    @anonymous ||= factory.build :anonymous
  end
end