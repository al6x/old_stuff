class Models::Files::Base
  inherit FileModel

  def model_id
    model._id || model._parent._id || raise("id not defined!")
  end

  def build_path name, version = nil
    "#{rad.models.fs['prefix']}/system/#{model.class.alias.underscore}/#{model_id}" + build_standard_path(name, version)
  end

  def build_url name, version = nil
    "#{rad.models.fs['host']}#{rad.models.fs['prefix']}/system/#{model.class.alias.underscore}/#{model_id}" + build_standard_url(name, version)
  end
end