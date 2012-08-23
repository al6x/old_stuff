# Handy configuration shortcuts, usage:
#
#     rad.configure app_dir do |c|
#       c.load_path :lib, :app
#     end
class Rad::Configurator
  attr_reader :dir

  def initialize dir
    @dir = File.expand_path dir
  end

  def asset_paths *paths
    resolve!(*paths).each{|path| rad.assets.paths << path unless rad.assets.paths.include? path}
  end

  def template_paths *paths
    resolve!(*paths).each{|path| rad.template.paths << path unless rad.template.paths.include? path}
  end

  # def routes *paths
  #   resolve(*paths).each{|path| load "#{path}.rb"}
  # end

  def locale_paths *paths
    resolve!(*paths).each{|path| rad.locale.paths += Dir["#{path}/*"]}
  end

  def load_paths *args
    if args.last == true
      paths = args[0..-2]
      watch_paths *paths
    else
      paths = args
    end
    resolve!(*paths).each{|path| $LOAD_PATH << path unless $LOAD_PATH.include? path}
  end

  def watch_paths *paths
    return unless rad.development?
    resolve!(*paths).each{|path| ClassLoader.watch path}
  end

  protected
    def resolve *paths
      paths.collect{|path| "#{dir}#{path}"}
    end

    def resolve! *paths
      resolve(*paths).collect do |path|
        raise "path #{path} not exist!" unless path.to_entry.exist?
        path
      end
    end
end