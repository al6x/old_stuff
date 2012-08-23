module AbstractInterface 
  class ViewBuilder
    
    def self.generate_helper_methods methods
      
      methods.each do |folder, templates|
        templates.each do |template|
          code = %{\
def #{template} *args, &block
  render_haml_builder "#{folder}", "#{template}", *args, &block
end}

          eval code, binding, __FILE__, __LINE__
        end
      end
      
    end
    
    
    attr_reader :template
    def initialize template
      @template = template
    end


    # 
    # Template methods
    # 
    PROXY_METHODS = %w{
      capture
      concat
      content_for
      content_tag
      render
      themed_partial
      themed_partial_exist?
      themed_resource            
    }
    PROXY_METHODS.each do |m|
      delegate m, :to => :template
    end
    
      
    # 
    # Builders
    #     
    def options *args, &block
      opt = args.extract_options!
      args.size.should! :be_in, 0..1
      opt[:content] = args.first if args.size == 1
      
      HamlBuilder.get_input self.template, opt, &block
      # options.should! :be_a, Hash
      # block.should! :be_a, Proc
      # if block
      #   b = HamlBuilder.new self.template
      #   block.call b
      #   options.merge b.get_value          
      # else
      #   options
      # end
    end        
    
    # 
    # Forms
    # 
    def form *args, &block
      b = FormBuilders::ThemedFormTagBuilder.new self.template
    
      options = {}.to_openobject
      prepare_form! options, *args
      
      # wrap_theme 'forms/begin', true do
        concat render(:partial => themed_partial('forms/begin'), :object => options)
        concat capture(b, &block)
        concat render(:partial => themed_partial('forms/end'), :object => options)
      # end
    end

    def form_for(record_or_name_or_array, *args, &proc)
      raise ArgumentError, "Missing block" unless block_given?

      options = args.extract_options!

      case record_or_name_or_array
      when String, Symbol
        object_name = record_or_name_or_array
        object = instance_variable_get "@#{record_or_name_or_array}"
      when Array
        object = record_or_name_or_array.last
        object_name = ActionController::RecordIdentifier.singular_class_name(object)
        self.template.apply_form_for_options!(record_or_name_or_array, options)
        args.unshift object
      else
        object = record_or_name_or_array
        object_name = ActionController::RecordIdentifier.singular_class_name(object)
        self.template.apply_form_for_options!([object], options)
        args.unshift object
      end

      # Rendering Form
      renderer_options = {}.to_openobject
      prepare_form! renderer_options, options.delete(:url) || {}, options.delete(:html) || {}
      
      # wrap_theme 'forms/begin', true do
        concat render(:partial => themed_partial('forms/begin'), :object => renderer_options)
    
        options[:builder] = FormBuilders::ThemedFormBuilder
        self.template.fields_for(object_name, *(args << options), &proc)

        concat render(:partial => themed_partial('forms/end'), :object => renderer_options)
      # end
    end
    
  
    private
      # # We need to wrap top-level default templates (for non-existing templates for current theme) inside '_d' div.
      # def wrap_theme partial, concat = false, &block
      #   unless themed_partial_exist? partial                    
      #     # we don't need _theme_wrapper for dialog and popup, it should be invisible
      #     classes = if AbstractInterface.dont_wrap_into_placeholder.include? partial
      #       "_d"
      #     else
      #       "_d _theme_wrapper"
      #     end
      #     
      #     if concat            
      #       self.concat %{<div class="#{classes}">}
      #       block.call
      #       self.concat %{</div>}              
      #     else
      #       html = block.call
      #       content_tag :div, html, :class => classes
      #     end
      #   else          
      #     block.call
      #   end
      # end
    
      def render_haml_builder folder, template, *args, &block
        opt = options *args, &block
        
        partial = "#{folder}/#{template}"

        # html = wrap_theme partial do
        html = render :partial => themed_partial(partial), :object => opt
        # end
        
        block ? self.concat(html) : html
      end
          
      def prepare_form! options, *args
        buff = template.form_tag *args
        options[:begin] = buff
        options[:end] = '</form>'
      end
  end
end