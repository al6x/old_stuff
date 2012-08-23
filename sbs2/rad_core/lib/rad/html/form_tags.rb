module Rad::Html::FormTags
  def form_tag options = {}, &block
    options[:method] ||= 'post'
    tag :form, options, &block
  end

  def form_for model_name, model, options = {}, &block
    model_helper = Rad::Html::ModelHelper.new self, model_name, model

    form_tag options do
      block.call model_helper if block
    end
  end

  def error_messages *errors
    errors = errors.first if errors.size == 1 and errors.first.is_a? Array
    html = errors.join("<br/>")
    tag :div, html, class: :error_messages
  end

  def field_with_errors name, errors, options, field_html
    html = tag :div, errors.join("<br/>"), class: :field_error_messages
    html << tag(:span, field_html, class: :field_with_errors)
    html
  end

  # Fields.

  def check_box_tag name, checked = false, options = {}
    options = {type: "checkbox", name: name, value: '1'}.update(options)
    options[:checked] = "checked" if checked
    tag_with_style :input, '', options
  end

  def field_set_tag legend = nil, options = {}, &block
    content = ""
    content << tag(:legend, legend) unless legend.blank?
    content << capture(&block)
    tag_with_style :fieldset, content, options
  end

  def file_field_tag name, options = {}
    text_field_tag name, nil, options.update(type: "file")
  end

  def hidden_field_tag name, value = '', options = {}
    text_field_tag(name, value, options.update(type: "hidden"))
  end

  def password_field_tag name, value = nil, options = {}
    text_field_tag(name, value, options.update(type: "password"))
  end

  def radio_button_tag name, value = '1', options = {}
    options = {type: "radio", name: name, value: value, checked: false}.update(options)
    checked = options.delete :checked
    options["checked"] = "checked" if checked
    tag_with_style :input, '', options
  end

  def select_tag name, selected, values, options = {}
    buff = "\n"
    values.each do |n, v|
      o = {}
      o[:value] = v if v
      o[:selected] = 'selected' if (v || n) == selected
      buff << tag(:option, n, o)
      buff << "\n"
    end

    tag_with_style :select, buff, {name: name}.update(options)
  end

  def text_field_tag name, value = '', options = {}
    tag_with_style :input, '', {type: "text", name: name, value: value}.update(options)
  end

  def text_area_tag name, value = '', options = {}
    tag_with_style :textarea, value, {name: name}.update(options)
  end

  def submit_tag value, options = {}
    tag_with_style :input, '', {type: "submit", value: value}.update(options)
  end

  protected
    def tag_with_style name, value, options, &block
      # Adding special class to fix with CSS some problems with fields displaying.
      klass = options.delete(:class) || options.delete('class') || ""
      klass << " #{options[:type] || options['type'] || name}_input"
      options['class'] = klass

      tag name, value, options, &block
    end
end