class FileModel::Version
  def initialize main, version_name
    @main, @version_name = main, version_name
  end

  def url
    name && build_url(name, version_name)
  end

  def file
    name && main.class.box[build_path(name, version_name)]
  end

  def process &block
    block.call original if original
  end

  protected
    attr_reader :main, :version_name

    delegate :original, :name, :build_path, :build_url, to: :main
end