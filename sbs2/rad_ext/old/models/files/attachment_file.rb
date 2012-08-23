class Models::Files::AttachmentFile < Models::Files::Base
  rad.extension :attachment_file_path, self do
    define_method :build_path do |*args|
      "#{rad.models.fs['prefix']}/#{model_id}" + build_standard_path(*args)
    end

    define_method :build_url do |*args|
      "#{rad.models.fs['prefix']}/#{model_id}" + build_standard_url(*args)
    end
  end

  version :icon do
    def process &block
      mini_magic block do |image|
        image.resize '50x50'
      end
    end
  end

  version :thumb do
    def process &block
      mini_magic block do |image|
        image.resize '150x150'
      end
    end
  end
end