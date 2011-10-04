module AbstractInterface
  module FormBuilders
    class ThemedFormBuilder < ActionView::Helpers::FormBuilder
      include AbstractFormBuilder
  
      helpers = field_helpers +
          %w{date_select datetime_select time_select} +
          %w{collection_select select country_select time_zone_select} -
          %w{hidden_field fields_for submit} # Don't decorate these

      helpers.each do |name|
        define_method(name) do |field, *args|
          options = args.extract_options!
          args << options
        
          label = if object.class.respond_to? :human_attribute_name
            object.class.try(:human_attribute_name, field)
          else
            object.t field
          end
        
          options[:label] = label unless options.include? :label

          inject_styles! options, name

          input = super field, *args

          remove_styles! options

          custom_helper input, options, field, object, *args
        end
      end
    
      def error_messages
        errors = object.errors.on(:base) || []
        custom_error_messages errors
      end

      protected
  
      def object
        @object ||= @template.instance_variable_get "@#{@object_name}"
      end
    end
  end
end