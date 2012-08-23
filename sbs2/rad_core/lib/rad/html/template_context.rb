class Rad::Html::TemplateContext < Rad::Template::Context
  include Rad::Html::CommonTags, Rad::Html::FormTags

  def indent str, indent
    # return str if rad.production?
    str.gsub /\n/, "\n#{" " * indent}"
  end
end