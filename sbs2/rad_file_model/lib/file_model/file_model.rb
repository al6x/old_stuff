module FileModel
  attr_reader :name
  attr_accessor :model

  def read name
    self.name = name
  end

  attr_reader :original
  def original= something
    @original = Adapter.new(something).to_file
    raise "file #{original.name} not exist!" unless original.exist?
    original
  end

  def save options = {}
    return true unless original

    # validating
    return false unless options[:validate] == false or valid?

    # deleting old files
    delete validate: false

    # saving
    self.name = build_name original.name

    process do |file|
      path = build_path name
      file.copy_to self.class.box[path]
    end

    self.class.versions.each do |version_name, klass|
      version = send version_name
      version.process do |file|
        path = build_path name, version_name
        file.copy_to self.class.box[path]
      end
    end

    true
  end

  def save! options = {}
    save(options) || raise("can't save #{self} (#{errors.inspect})!")
  end

  def delete options = {}
    return true unless name

    return false unless options[:validate] == false or valid?

    path = build_path name
    self.class.box[path].delete

    self.class.versions.each do |version_name, klass|
      path = build_path name, version_name
      self.class.box[path].delete
    end

    true
  end

  def delete! options = {}
    delete(options) || raise("can't delete #{self} (#{errors.inspect})!")
  end

  def url
    name && build_url(name)
  end

  def file
    name && self.class.box[build_path(name)]
  end

  def process &block
    block.call original if original
  end

  def build_standard_path name, version = nil
    base, extension = name.rsplit('.', 2)
    %(/#{base}#{".#{version}" if version}#{".#{extension}" if extension})
  end
  alias_method :build_path, :build_standard_path

  def build_standard_url name, version = nil
    base, extension = name.rsplit('.', 2)
    %(/#{base}#{".#{version}" if version}#{".#{extension}" if extension})
  end
  alias_method :build_url, :build_standard_url

  def build_name name
    name
  end

  def errors
    @errors ||= []
  end

  def valid?
    errors.clear
    run_validations
    errors.empty?
  end

  def run_validations; end

  class << self
    def box name
      raise "Override this method to provide Your own custom box initialization."
    end

    attr_accessor :box
    attr_required :box
  end

  protected
    attr_writer :name

  module ClassMethods
    inheritable_accessor :versions, {}

    def version name, &block
      klass = Class.new FileModel::Version, &block
      versions[name] = klass

      iv_name = :"@#{name}"
      define_method name do
        unless version = instance_variable_get(iv_name)
          version = klass.new self, name
          instance_variable_set iv_name, version
        end
        version
      end
    end

    inheritable_accessor :box_name, :default
    def box name = nil
      if name
        self.box_name = name
      else
        FileModel.box box_name
      end
    end
  end
end