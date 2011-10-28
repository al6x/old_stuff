warn 'remove fake_gem'

# If you inject this module wia RUBYOPTS it may be already be processed,
# and include('fake_gem') will executes it one more time, so we check it manually.
unless defined?(FakeGem) or defined?(JRuby)
  class LoadError
    attr_accessor :raised_in_fake_gem
  end

  $indent = -1
  Kernel.class_eval do
    alias :gem_without_fgem :gem
    def gem name, *version_requirements
      gem_without_fgem name, *version_requirements
    rescue Gem::LoadError => e

      # need this check to prevent very tricky bug caused by recursive retry and resulting in
      # files will be required multiple times and strange error messages will be produced
      raise e if e.raised_in_fake_gem

      unless FakeGem.activate_gem(name)
        e.raised_in_fake_gem = true
        raise e
      end
    end

    alias :require_without_fgem :require
    def require path
      require_without_fgem path
    rescue LoadError => e

      # need this check to prevent very tricky bug caused by recursive retry and resulting in
      # files will be required multiple times and strange error messages will be produced
      raise e if e.raised_in_fake_gem

      if FakeGem.activate(path + '.rb')
        retry
      else
        e.raised_in_fake_gem = true
        raise e
      end
    end

    alias :load_without_fgem :load
    def load path, wrap = false
      load_without_fgem path, wrap
    rescue LoadError => e

      # need this check to prevent very tricky bug caused by recursive retry and resulting in
      # files will be required multiple times and strange error messages will be produced
      raise e if e.raised_in_fake_gem

      if FakeGem.activate(path)
        retry
      else
        e.raised_in_fake_gem = true
        raise e
      end
    end
  end

  module FakeGem
    class FakeGemSpec
      attr_reader :dir, :name, :libs
      def initialize file
        should_exist file
        @dir, @libs = File.expand_path(File.dirname(file)), []

        spec = parse file
        self.name, self.libs = spec['name'], Array(spec['libs'])
      end

      def inspect
        relative_libs = @libs.collect{|l| l.sub("#{@dir}/", '')}
        "fake gem #{@dir} (#{relative_libs.join(', ')})"
      end
      alias_method :to_s, :inspect


      protected
        def parse file
          options = {}
          File.read(file).split("\n").select{|line| line !~ /^#|^\s*$/}.each do |line|
            key, value = line.split /\s*:\s*/, 2
            options[key] = value
          end
          options
        end

        def should_exist file, msg = "file '%{file}' not exist!"
          raise msg.sub('%{file}', file) unless File.exist? file
          file
        end

        def libs= libs
          libs = libs.collect do |d|
            d = d.to_s
            d = (d =~ /^\//) ? d : "#{dir}/#{d}"
            should_exist d, "file '%{file}' not exist (folder '#{dir}' is false_gem but the folder declared as :lib not exist)!"
            d
          end
          @libs = libs
        end

        attr_writer :name
    end

    class << self
      # Use it to set location for Your fake_gems
      def paths *paths
        paths = paths.first if paths.first.is_a? Array
        if paths.empty?
          unless @paths
            if env_paths = ENV['FAKE_GEM_PATHS']
              self.paths = env_paths.split(':')
            else
              self.paths = []
            end
          end
          @paths
        else
          self.paths = paths
        end
      end

      def paths= paths
        @paths = paths.collect{|l| File.expand_path l}
      end

      # searches for that path in all libs inside of registered fake_gems and
      # updates $LOAD_PATH if found.
      def activate path
        found = nil
        catch :found do
          gems.each do |gem_spec|
            gem_spec.libs.each do |lib_path|
              if File.exist? "#{lib_path}/#{path}"
                found = gem_spec
                throw :found
              end
            end
          end
        end

        if found
          gems.delete found
          found.libs.each do |lib_path|
            $LOAD_PATH << lib_path unless $LOAD_PATH.include? lib_path
          end
          true
        else
          false
        end
      end

      # searches for that path in all libs inside of registered fake_gems and
      # updates $LOAD_PATH if found.
      def activate_gem name
        found = gems.find{|gem_spec| gem_spec.name && (gem_spec.name == name)}

        if found
          gems.delete found
          found.libs.each do |lib_path|
            $LOAD_PATH << lib_path unless $LOAD_PATH.include? lib_path
          end
          true
        else
          false
        end
      end

      # list of found false-gems
      def gems
        unless @gems
          @gems = []
          paths.each do |location|
            Dir.glob("#{location}/*/fake_gem").each do |gem_spec_file|
              @gems << FakeGemSpec.new(gem_spec_file)
            end
          end
        end
        @gems
      end
      attr_writer :gems

      def clear
        @paths, @gems = nil
      end

    end
  end
end