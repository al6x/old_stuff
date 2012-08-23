# 
# content_or_self
# 
[Hash, OpenObject].each do |aclass|
  aclass.class_eval do 
    def hash?; true end
  end
end

NilClass.class_eval do
  def content; "" end
  def hash?; false end
end

String.class_eval do
  def content; self end
  def hash?; false end
end

# OpenObject
OpenObject.class_eval do
  def merge_html_attributes *a
    raise "invalid usage, something wrong goin on, this method should be called only from instance of HtmlOpenObject class!"
  end
  alias_method :merge_html_attributes?, :merge_html_attributes
  alias_method :merge_html_attributes!, :merge_html_attributes
end


# 
# Automaticaly add content of action view to the :content content variable,
# to eliminate need for "content_for :content do ..." stuff.
# 
Rad::Controller::Abstract::Render.class_eval do
  protected
    def render_content_with_content options
      context = options[:context]      
      content = render_content_without_content options
      context.content_for :content, content if context
      return content
    end
    alias_method_chain :render_content, :content
end