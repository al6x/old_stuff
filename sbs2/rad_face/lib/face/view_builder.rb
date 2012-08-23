class Rad::Face::ViewBuilder

#   def self.generate_view_helper_methods methods      
#     methods.each do |folder, templates|
#       templates.each do |template|
#         code = %{\
# def #{template} *args, &block
#   render_block "#{folder}", "#{template}", *args, &block
# end}
# 
#         eval code, binding, __FILE__, __LINE__
#       end
#     end      
#   end    

  attr_reader :template
  def initialize template
    @template = template
  end


  # 
  # Template methods
  # 
  %w(
    capture
    concat
    content_for
    tag
    render
    themed_partial
    controller    
  ).each do |m|
    delegate m, to: :template
  end

  
  # 
  # Builders
  #     
  def options *args, &block
    opt = args.extract_options!
    args.size.must.be_in 0..1
    opt[:content] = args.first if args.size == 1
  
    Rad::Face::HamlBuilder.get_input self.template, opt, &block
  end        


  # 
  # Forms
  # 
  def form_tag *args, &block
    f = Rad::Face::ThemedFormHelper.new(template)    
  
    content = block ? capture{block.call(f)} : ""             
    object = Rad::Face::HtmlOpenObject.initialize_from(form_attributes: args, content: content)
    html = render(
      themed_partial('/forms/form'), 
      object: object
    )
  
    if block
      template.concat html
    else
      html
    end
  end

  def form_for *args, &block
    model_helper, options = template.build_form_model_helper_and_form_options *args
        
    form_tag options do |themed_form_helper|
      model_helper.form_helper = themed_form_helper
    
      block.call model_helper if block
    end
  end    

  def render_block template, *args, &block
    opt = options *args, &block
    html = render themed_partial(template), object: opt
    block ? self.concat(html) : html
  end
      
  def prepare_form! options, *args
    buff = template.form_tag *args
    options[:begin] = buff
    options[:end] = '</form>'
  end
  
  protected
    def method_missing m, *args, &block
      render_block "/#{m}", *args, &block
    end
end