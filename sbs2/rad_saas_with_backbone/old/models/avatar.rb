class Models::User
  # Avatar.
  inherit Mongo::Model::FileModel
  mount_file :avatar, Models::Files::Avatar
  def self.avatar_url user_name
    "#{rad.users.avatars_path}/avatars/#{user_name}.icon"
  end
end

class Models::Files::Avatar < Models::Files::Base
  def build_path name, version = nil
    "#{rad.models.fs['prefix']}/avatars" + build_standard_path(model.name, version)
  end

  def build_url name, version = nil
    "#{rad.models.fs['host']}#{rad.models.fs['prefix']}/avatars" + build_standard_url(model.name, version)
  end

  version :icon do
    def process &block
      mini_magic block do |image|
        image.resize '50x50'
      end
    end
  end
end