class FileModel::Adapter
  def initialize something
    @something = something
  end

  def to_file
    self.class.clear_expired_cache

    if something.respond_to? :to_file
      something.to_file
    elsif something.is_a? Hash
      data = something["tempfile"] || something[:tempfile] || raise("no file!")
      name = something["filename"] || something[:filename] || raise("no filename!")
      file = "#{self.class.cache_dir}/#{name}".to_file
      file.write data.read
      file
    elsif something.is_a? File
      path = something.path
      name = File.basename path
      file = "#{self.class.cache_dir}/#{name}".to_file
      file.write something.read
      file
    else
      raise "unknown file format!"
    end
  end

  EXPIRATION_TIME = 5
  BASE_DIR = "/tmp/file_model_cache"

  class << self
    def cache_dir
      "#{BASE_DIR}/#{Time.now.min}/#{rand(1_000_000)}"
    end

    def clear_expired_cache
      time = Time.now.min
      dir = BASE_DIR.to_dir
      if dir.exist?
        dir.to_dir.entries do |entry|
          entry_time = entry.name.to_i
          entry.delete if (entry_time > time) or (time > (entry_time + EXPIRATION_TIME))
        end
      end
    end
  end

  protected
    attr_reader :something
end