module AbstractInterface
  module FormBuilders
    module AbstractFormBuilder
  
      attr_reader :template
  
      def line *items
        template.render :partial => template.themed_partial('forms/line'), :object => {:items => items, :delimiter => false}.to_openobject
      end
  
      def submit *args
        @template.submit_tag *args
      end
  
      # def hidden_field_tag *args
      #   result[:hidden_fields] << @template.hidden_field_tag(*args)
      # end
  
      def line_with_delimiters *items
        template.render :partial => template.themed_partial('forms/line'), :object => {:items => items, :delimiter => true}.to_openobject
      end
  
      # text_field_tag, ... xxx_tag
      def method_missing name, *args, &block
        options = args.extract_options!.symbolize_keys
        args << options

        inject_styles! options, name

        input = @template.send name, *args, &block

        remove_styles! options

        custom_helper input, options, name, options[:object], *args
      end
  
      def error_messages *errors
        if errors.size == 1 and errors.first.is_a?(Array)
          custom_error_messages *errors
        else
          custom_error_messages errors
        end
      end
      
      def field_tag html, options = {}
        custom_helper html, options, nil, options[:object]
      end
  
      protected
        def custom_helper input, options, field, object, *args
          # Input
          options[:input] = input

          # Errors
          errors = options[:errors] || (object ? (object.errors.on(field) || []) : [])
          errors = [errors] unless errors.is_a?(Array)
          options[:errors] = errors

          template.render :partial => template.themed_partial('forms/field'), :object => options.to_openobject
        end
  
        def custom_error_messages errors
          errors = [errors] unless errors.is_a?(Array)
          template.render :partial => template.themed_partial('forms/errors'), :object => errors
        end
  
        def inject_styles! options, name
          name = name.to_s.sub(/_tag$/, "")
          options[:class] ||= "";
          options[:class] << " themed_input #{name}_input"
        end
  
        def remove_styles! options
          options.delete :class
          options.delete 'class' # sometimes it's a String
        end
    end
  end
end