class Rad::Face::ThemedFormHelper
  attr_accessor :template

  def initialize template
    self.template = template
  end

  def error_messages *errors
    errors = errors.first if errors.size == 1 and errors.first.is_a? Array
    template.render template.themed_partial('/forms/errors'), object: errors
  end

  def form_field options, &block      
    html_options = options.to_openobject
    options = Rad::Face::HtmlOpenObject.new
  
    # prepare options
    %w(errors label description required theme).each do |k| 
      v = html_options.delete k
      options[k] = v unless v.nil?
    end
    options.errors = options.errors.to_a

    # CSS style
    html_options.class ||= ""
    html_options << " themed_input"
  
    options.content = template.capture{block.call(html_options)}
  
    html = template.render(template.themed_partial('/forms/field'), object: options)
    template.concat html
  end

  def line *items
    object = Rad::Face::HtmlOpenObject.initialize_from(items: items)
    template.render template.themed_partial('/forms/line'), object: object
  end    
  
  def self.generate_form_helper_methods methods
    methods.each do |m|
      define_method m do |*args|
        options = args.extract_options!
        template.capture do
          form_field options do |html_options|
            args << html_options
            template.concat(template.send(m, *args))
          end
        end
      end
    end
  end


  # 
  # Form fields
  # 
  methods = %w(
    check_box_tag
    field_set_tag
    file_field_tag      
    password_field_tag
    radio_button_tag
    select_tag
    text_field_tag
    text_area_tag        
  )
  generate_form_helper_methods methods  

  %w(
    hidden_field_tag
    submit_tag
  ).each{|m| delegate m, to: :template}

end