STRONG_NAME = /\A[a-z_][a-z_0-9]*\Z/

ActiveSupport::CoreExtensions::Module.class_eval do
  def model_name
    @model_name ||= ::ActiveSupport::ModelName.new(name_alias)
  end
end
