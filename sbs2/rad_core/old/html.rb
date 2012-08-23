class Html
  inject :template

  def render *args, &block
    options = template.parse_arguments *args
    template.render context: Html::TemplateContext.new, &block
  end
end