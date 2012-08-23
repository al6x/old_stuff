# Adding filtering specs with focus.
RSpec.configure do |c|
  c.filter_run focus: true
  c.run_all_when_everything_filtered = true
end

# Shortcut for extending RSpec.
def rspec &block
  RSpec::Core::ExampleGroup.class_eval &block if block
  return RSpec::Core::ExampleGroup
end

# Shortcut for defining matchers.
rspec do
  def self.define_matcher *args, &block
    RSpec::Matchers.define *args do |expected|
      match do |actual|
        block.call actual, expected if block
      end
    end
  end
end

rspec do
  def remove_constants *args
    args = args.first if args.size == 1 and args.first.is_a?(Array)
    args.each{|c| Object.send :remove_const, c if Object.const_defined? c}
  end

  # Before and after all shortcuts.
  def self.before_all &block; before :all, &block end
  def self.after_all &block; after :all, &block end

  # Helpers for working with $LOAD_PATH.
  def self.with_load_path *paths
    before_all{paths.each{|path| $LOAD_PATH << path}}
    after_all{paths.each{|path| $LOAD_PATH.delete path}}
  end
  def with_load_path *paths, &b
    begin
      paths.each{|path| $LOAD_PATH << path}
      b.call
    ensure
      paths.each{|path| $LOAD_PATH.delete path}
    end
  end

  # Helpers for working with spec directories and temp directories.

  def self.with_tmp_spec_dir *args
    options = args.last.is_a?(Hash) ? args.pop : {}
    dir = args.first || self.spec_dir

    options[:before] ||= :all
    tmp_dir = "/tmp/#{dir.split('/').last}"

    before options do
      require 'fileutils'

      FileUtils.rm_r tmp_dir if File.exist? tmp_dir
      FileUtils.cp_r dir, tmp_dir
      @spec_dir = tmp_dir
    end

    after options do
      FileUtils.rm_r tmp_dir if File.exist? tmp_dir
      @spec_dir = nil
    end

    tmp_dir
  end

  def self.with_spec_dir dir
    before_all{@spec_dir = dir}
    after_all{@spec_dir = nil}
  end

  def self.spec_dir
    self.calculate_default_spec_dir || raise(":spec_dir not defined!")
  end

  def spec_dir
    @spec_dir || self.class.spec_dir
  end

  protected
    def self.calculate_default_spec_dir
      spec_file_name = caller.find{|line| line =~ /_spec\.rb\:/}
      return nil unless spec_file_name
      spec_dir = spec_file_name.sub(/\.rb\:.*/, '')
      raise "spec dir not exist (#{spec_dir})!" unless File.exist? spec_dir
      spec_dir
    end
end

# Stubbing every instances of class.
class Class
  def after_instantiate &block
    new_method = method :new
    stub! :new do |*args|
      instance = new_method.call *args
      block.call instance
      instance
    end
  end
end