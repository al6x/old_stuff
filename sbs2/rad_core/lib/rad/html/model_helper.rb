class Rad::Html::ModelHelper
  attr_accessor :form_helper, :model_name, :model

  def initialize form_helper, model_name, model
    self.form_helper, self.model_name, self.model = form_helper, model_name, model
  end

  # Fields.

  def check_box name, options = {}
    render_attribute name, options do |fname, value, o|
      html = form_helper.hidden_field_tag(fname, '0') + "\n"
      html += form_helper.check_box_tag fname, !!value, o
      html
    end
  end

  def file_field name, options = {}
    render_attribute name, options do |fname, value, o|
      form_helper.file_field_tag fname, o
    end
  end

  def hidden_field name, options = {}
    render_attribute name, options do |fname, value, o|
      form_helper.hidden_field_tag fname, value, o
    end
  end

  def password_field name, options = {}
    render_attribute name, options do |fname, value, o|
      form_helper.password_field_tag fname, nil, o
    end
  end

  def radio_button name, value = 1, options = {}
    render_attribute name, options do |fname, v, o|
      o[:checked] = value == v
      form_helper.radio_button_tag fname, value, o
    end
  end

  def submit value, options = {}
    form_helper.submit_tag value, options
  end

  def text_field name, options = {}
    render_attribute name, options do |fname, value, o|
      form_helper.text_field_tag fname, value, o
    end
  end

  def text_area name, options = {}
    render_attribute name, options do |fname, value, o|
      form_helper.text_area_tag fname, value, o
    end
  end

  def select name, values, options = {}
    render_attribute name, options do |fname, value, o|
      form_helper.select_tag fname, value, values, o
    end
  end

  def error_messages
    merrors = errors[:base]
    form_helper.error_messages merrors.to_a unless merrors.blank?
  end


  protected
    def method_missing m, *args, &b
      form_helper.send m, *args, &b
    end

    def render_attribute name, options, &block
      name.must.be_a Symbol
      ferrors = errors_for(name)

      options = insert_human_readable_label name, options

      value = value_of name
      field_name = field_name_for name, value

      if form_helper.respond_to? :field_with_errors
        field_html = block.call field_name, value, options
        unless ferrors.blank?
          form_helper.field_with_errors name, ferrors, options, field_html
        else
          field_html
        end
      else
        options[:errors] = ferrors
        block.call field_name, value, options
      end
    end

    def errors
      unless @errors
        @errors = {}
        (
          (model.respond_to?(:errors) && model.errors) ||
          (model.respond_to?(:[]) && (model['errors'] || model[:errors])) ||
          {}
        ).each do |k, v|
          @errors[k.to_sym] = Array.wrap(v)
        end
      end
      @errors
    end

    def errors_for name
      name.must.be_a Symbol
      errors[name]
    end

    def field_name_for name, value
      if value.is_a? Array
        "#{model_name}[#{name}][]"
      else
        "#{model_name}[#{name}]"
      end
    end

    def value_of name
      if model.respond_to? name
        model.send name
      elsif model.respond_to? :[]
        model[name.to_sym] || model[name.to_s]
      else
        raise "model does not respond to :#{name} nor to :[] (#{model.inspect})!"
      end
    end

    def insert_human_readable_label name, options
      unless options.include?(:label)
        options[:label] = model.t(name) if model.respond_to? :t
      end
      options
    end
end