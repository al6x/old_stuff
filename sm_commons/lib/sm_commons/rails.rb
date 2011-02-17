Rails.class_eval do
  class << self
    def multitenant_mode?
      Space.current?
    end
  end
end