require 'tilt'
require 'rad/template/_tilt'
require 'rad/template/_tilt_fixes'

class Rad::Template
  # Configuration.
  attr_accessor :prefixes, :ugly
  attr_required :prefixes, :ugly
  def ugly?; !!ugly end

  attr_accessor :relative_path_resolver

  def initialize
    @relative_path_resolver = RelativePathResolver.new
  end

  def render *args, &block
    result, context = basic_render(parse_arguments(*args), &block)
    result
  end

  def render_html *args, &block
    options = rad.template.parse_arguments *args
    options[:context] ||= Rad::Html::TemplateContext.new
    result, context = basic_render(options, &block)
    result
  end

  def exist? tname, options = {}
    !!find_template(tname, options)
  end

  def read tname, options = {}
    file = find_template(tname, options) || raise("no template '#{tname}'!")
    File.read file
  end

  def basic_render options, &block
    with_context options do |context|
      context.content_block ||= block

      with_scope options, context do |scope|
        file = (
          options[:file] ||
          find_template(options[:template], options.merge(scope)) ||
          (options[:if_not_exist] && find_template(options[:if_not_exist], options.merge(scope))) ||
          raise("no template '#{options[:template]}'!")
        )

        scope[:current_dir] = dirname(file)

        template = create_tilt_template file

        result = with_template context, template do
          render_template template, context, options, &context.content_block
        end

        return result, context
      end
    end
  end

  def parse_arguments *args
    options = args.extract_options!
    if args.size == 1
      options[:template] = args.first
    else
      raise "Invalid input" if args.size != 0
    end

    options
  end

  def find_file tname, prefixes, format, exact_format, directories
    prefixes = prefixes || self.prefixes
    prefixes.each do |prefix|
      tname = template_name_with_prefix("#{directory_name}#{tname}", prefix)
      file = if tname.include? '.'
        _find_file(tname, directories) || _find_file("#{tname}.*", directories)
      else
        if format
          _find_file("#{tname}.#{format}.*", directories) or
            _find_file("#{tname}.*", directories, exact_format)
        else
          _find_file("#{tname}.*", directories)
        end
      end
      return file if file
    end
    return nil
  end

  def directory_name; "" end

  def paths; @paths ||= [] end

  protected
    # with_one_extension - 'tname.*' matches not only 'tname.erb' but also 'tname.html.erb',
    # with this option enabled it will not match 'tname.html.erb', only 'tname.erb'
    def _find_file pattern, directories, with_one_extension = false
      files = rad.environment.find_files_by_pattern_without_cache pattern, directories
      files = files.select{|f| f !~ /\.[^\.\/]+\.[^\.\/]+$/} if with_one_extension
      raise "multiple templates for '#{pattern}'!" if files.size > 1
      files.first
    end

    def template_name_with_prefix tname, prefix
      index = tname.rindex('/')
      index = index ? index + 1 : 0
      tname = tname.clone
      tname.insert index, prefix
    end

    def with_context options, &block
      context = Thread.current[:render_context] || options[:context] || Context.new(options[:instance_variables])

      old = Thread.current[:render_context]
      begin
        Thread.current[:render_context] = context
        block.call context
      ensure
        Thread.current[:render_context] = old
      end
    end

    def with_scope options, context, &block
      initial = context.scope_variables

      old = context.scope_variables || OpenObject.new
      begin
        context.scope_variables = {
          current_dir: (options[:current_dir] || old[:current_dir]),
          format: (options[:format] || old[:format]),
          relative_path_resolver: (options[:relative_path_resolver] || old[:relative_path_resolver])
        }

        block.call context.scope_variables
      ensure
        context.scope_variables = old if initial
      end
    end

    def with_template context, template, &block
      old = context._tilt_template
      begin
        context._tilt_template = template
        block.call context
      ensure
        context._tilt_template = old
      end
    end

    def dirname path;
      File.dirname path
    end
    cache_method_with_params_in_production :dirname

    def find_template tname, options
      tname.must.be_a String
      # splitted into two to optimize cache
      if tname =~ /^\//
        find_absolute_template tname, options[:prefixes], options[:format], options[:exact_format]
      else
        resolver = options[:relative_path_resolver] || relative_path_resolver
        resolver.find_relative_template tname, options[:prefixes], options[:format], options[:exact_format], options[:current_dir]
      end
    end

    def find_absolute_template tname, prefixes, format, exact_format
      prefixes = prefixes || self.prefixes
      find_file(tname, prefixes, format, exact_format, paths)
    end
    cache_method_with_params_in_production :find_absolute_template

    def create_tilt_template path
      # register_slim_template

      Tilt.new(path, nil, ugly: ugly?, outvar: "@output"){|t| File.read(t.file)}
    end
    cache_method_with_params_in_production :create_tilt_template

    def render_template template, context, options, &block
      locals = options[:locals] || {}
      if object = options[:object]
        locals[:object] = object
      end

      template.render context, locals, &block
    end

    # # Lazy initialization of slim templates, Tilt doesn't know about slim,
    # # so we need to do it by hand.
    # def register_slim_template
    #   return if @slim_template_enabled
    #   @slim_template_enabled = true
    #
    #   begin
    #     require 'slim'
    #     Slim::Engine.set_default_options :pretty => !ugly?
    #   rescue NameError
    #   end
    # end
end