class Rad::Template::Context
  include Tilt::CompileSite, Tilt::ContextExt
  attr_accessor :_tilt_template

  inject :template

  # For saving template related variables like :format, :current_dir and others.
  attr_accessor :scope_variables

  def initialize instance_variables = nil
    set_instance_variables! instance_variables if instance_variables
  end

  delegate :render, to: :template

  # Content variables.

  attr_accessor :content_block

  def content_variables; @content_variables ||= {}.to_openobject end

  def content_for name, content = nil, &block
    content ||= capture(&block)
    (content_variables[name.to_s] ||= "") << content
    nil
  end

  def prepend_to name, content = nil, &block
    content ||= capture(&block)
    (content_variables[name.to_s] ||= "").insert 0, content
    nil
  end

  def wrap_content_for name, &block
    block.must.be_defined
    content = capture((content_variables[name.to_s] || ""), &block)
    content_variables[name.to_s] ||= content
    nil
  end

  def has_content_for? name
    content_variables.include? name.to_s
  end

  def t *args; rad.locale.t *args end

  protected
    def set_instance_variables! instance_variables
      instance_variables = [instance_variables] unless instance_variables.is_a? Array
      instance_variables.each do |container|
        if container.is_a? Hash
          container.each do |name, value|
            instance_variable_set("@#{name}", value)
          end
        else
          container.instance_variables.each do |ivname|
            iv = container.instance_variable_get(ivname)
            instance_variable_set(ivname, iv)
          end
        end
      end
    end
end