# fixing known YAML problem with gems
require 'yaml'
require 'psych'
YAML::ENGINE.yamler = 'syck'


#
# Helper for releasing gem, add following code to Your Rakefile:
#
#   project \
#     name: "fake_gem",
#     gem: true,
#     summary: "Makes any directory looks like Ruby Gem",
#
#     bin: 'bin',
#     executables: ['fake_gem'],
#     dirs: %w(bin),
#
#     author: "Alexey Petrushin",
#     homepage: "http://github.com/alexeypetrushin/fake_gem"
#
# use "rake gem" to release gem
#

require 'rubygems/specification'

class GemHelper
  class << self
    def next_version gem_name
      %x(gem list --remote #{gem_name}).scan /#{gem_name} \((\d+\.\d+\.\d+)\)/ do |s|
        v = s.first.split('.').collect{|d| d.to_i}
        v[-1] = v[-1] + 1
        return v.join('.')
      end
      return '0.0.1'
    end

    def parse_project_gemfile
      required_gems, required_fake_gems = [], []
      gem_file = "#{project_dir}/lib/#{project[:name]}/gems.rb"

      if File.exist? gem_file
        # puts "Parsing gemfile #{gem_file}"

        code = File.open(gem_file){|f| f.read}

        stub_class = Class.new
        stub_class.send(:define_method, :gem){|*args| required_gems << args}
        stub_class.send(:define_method, :fake_gem){|*args| required_fake_gems << args}
        stub = stub_class.new
        stub.instance_eval code, __FILE__, __LINE__
      end

      return required_gems, required_fake_gems
    end

    def gemspec
      Gem::Specification.new do |s|
        gems, fake_gems = parse_project_gemfile
        gems = gems + fake_gems

        gems.each{|name_version| s.add_dependency *name_version}

        options = project.clone

        options.delete(:name)
        options.delete(:gem) || raise("this project isn't a gem!")
        name = options.delete(:official_name)

        s.name = name
        s.platform = options.delete(:platform) || Gem::Platform::RUBY
        s.has_rdoc = options.delete(:has_rdoc) == nil ? false : true
        s.require_path = options.delete(:lib) || "lib"
        s.files = options.delete(:files) || (
          %w{Rakefile readme.md} +
          Dir.glob("{lib,spec}/**/*") +
          ((options[:dirs] && Array(options.delete(:dirs)).collect{|d| Dir["#{d}/**/*"]}) || [])
        )
        s.bindir = options.delete(:bin) if options.include? :bin

        s.version = options.delete(:version) || GemHelper.next_version(name)

        options.each{|k, v| s.send "#{k}=", v}
      end
    end
  end
end

namespace :gem do
  desc "Build and release gem"
  task :release do
    puts '  configuring'
    gemspec = GemHelper.gemspec
    gemspec_file = "#{gemspec.name}.gemspec"
    File.open(gemspec_file, 'w'){|f| f.write gemspec.to_ruby}

    puts '  building'
    %x(gem build #{gemspec_file})

    puts '  pushing'
    gem_file = Dir.glob("#{gemspec.name}*.gem").first
    %x"gem push #{gem_file}"

    puts '  cleaning'
    [gemspec_file, gem_file].each{|f| File.delete f if File.exist? f}

    puts "  #{gemspec.name} #{gemspec.version} successfully released"
  end

  desc "Install gem required by project"
  task :install do
    gems, fake_gems = GemHelper.parse_project_gemfile
    gems.each do |name, version|
      puts "Installing gem #{name} #{version}"
      %x(gem install #{name}#{" -v #{version}" if version}) # --ignore-dependencies)
    end
  end

  desc "List all gems required by project"
  task :list do
    puts "Gems required for #{project[:official_name]}:"
    gems, fake_gems = GemHelper.parse_project_gemfile
    puts(gems + fake_gems)
  end

  desc "Install all gem required by project (including fake gems)"
  task :install_all do
    gems, fake_gems = GemHelper.parse_project_gemfile
    (gems + fake_gems).each do |name, version|
      puts "Installing gem #{name} #{version}"
      %x(gem install #{name} #{"-v #{version}" if version})
    end
  end
end