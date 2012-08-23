module Rad::Controller::Abstract::Render
  SPECIAL_FORMAT_HANDLERS = {
    json: lambda{|o| o.to_json},
    xml: lambda{|o| o.to_xml},
    js: lambda{|o| o},
  }

  def _layout *args
    @_layout = *args unless args.empty?
    @_layout
  end
  def _layout= layout
    @_layout = layout
  end

  def render *args
    options = rad.template.parse_arguments *args

    instance_variables = {
      controller_name: self.class.controller_name
    }

    instance_variable_names.each do |name|
      instance_variables[name[1..-1]] = instance_variable_get name unless name =~ /^@_/
    end

    instance_variables[:action_name] = options[:action] if options[:action]

    context = self.class.context_class.new(instance_variables, self)

    options.reverse_merge! \
      context: context,
      format: params.format,
      exact_format: true,
      relative_path_resolver: self.class

    content = render_content options
    content = render_layout content, options

    throw :halt, content
  end

  def render_json obj
    render json: obj
  end

  protected
    def render_content options
      if special_format = SPECIAL_FORMAT_HANDLERS.keys.find{|f| options.include? f}
        handler = SPECIAL_FORMAT_HANDLERS[special_format]
        if special_format.to_s != params.format
          raise "You trying responing with '#{special_format}' to the '#{params.format}' requested format!"
        end
        handler.call options[special_format]
      elsif options.include? :inline
        options[:inline]
      elsif options[:template] == :nothing
        ''
      else
        if action = options.delete(:action)
          options[:template].must.be_blank
          options[:template] = action

          options.reverse_merge! \
            prefixes: [''],
            if_not_exist: '/rad_default_templates/blank_template'
        end
        options[:template].must.be_present
        options[:template] = options[:template].to_s

        rad.template.render options
      end
    end

    def render_layout content, options
      layout = options.include?(:layout) ? options[:layout] : self._layout

      if layout and rad.template.exist? layout, options
        options = options.merge template: layout
        rad.template.render options do |*args|
          if args.empty?
            content
          else
            args.size.must.be == 1
            variable_name = args.first.to_s
            options[:context].content_variables[variable_name]
          end
        end
      else
        content
      end
    end

  module ClassMethods
    def layout layout, options = {}
      before options do |controller|
        controller._layout = layout
      end
    end

    def context_class
      unless @context_class
        parent_context_class = nil
        ancestors[1..-1].each do |anc|
          break if parent_context_class = anc.respond_to(:context_class)
        end
        parent_context_class ||= Rad::Controller::Context

        class_name = "#{self.name}::#{self.name.split('::').last}Context"

        # raise "Tempate context #{class_name} already defined!" if Object.const_defined? class_name
        eval "class #{class_name} < #{parent_context_class}; end", TOPLEVEL_BINDING, __FILE__, __LINE__
        @context_class = class_name.constantize
      end
      @context_class
    end

    def find_relative_template *args
      return _find_relative_template *args unless rad.production?

      # use cache
      @relative_template ||= {}
      unless @relative_template.include? args
        @relative_template[args] = _find_relative_template *args
      end
      @relative_template[args]
    end

    def _find_relative_template tname, prefixes, format, exact_format, current_dir
      tname.must.be_present

      path = nil

      # own templates
      ["/#{controller_name.underscore}/#{tname}", "/#{controller_name.gsub('::', '/')}/#{tname}"].each do |name|
        path ||= rad.template.find_file(name, prefixes, format, exact_format, rad.template.paths)
      end

      # own :actions templates
      ["/#{controller_name.underscore}/actions", "/#{controller_name.gsub('::', '/')}/actions"].each do |name|
        unless path
          path = rad.template.find_file(name, prefixes, format, exact_format, rad.template.paths)
          path = nil if path and (File.read(path) !~ /^.*when.+[^_a-zA-Z0-9]#{tname}[^_a-zA-Z0-9].*$/)
        end
      end

      # superclasses templates
      unless path
        parent = ancestors[1..-1].find{|a| a.respond_to?(:find_relative_template)} #  and a.instance_methods.include?(action)
        if parent and parent != Rad::Controller::Abstract
          path = parent.find_relative_template(tname, prefixes, format, exact_format, current_dir)
        end
      end

      # relative template
      if !path and current_dir
        path = rad.template.relative_path_resolver.find_relative_template(tname, prefixes, format, exact_format, current_dir)
      end

      return path
    end

  end
end