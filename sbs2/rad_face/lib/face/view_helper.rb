module Rad::Face::ViewHelper
  inject theme: :theme

  def b
    @b ||= Rad::Face::ViewBuilder.new self
  end
  alias_method :builder, :b

  def unique_id
    @unique_id ||= 0
    @unique_id += 1
  end

  def themed_partial partial
    partial.must =~ /^\//
    themed_partial = "#{rad.face.themes_path}/#{theme.name}#{partial}"
    if rad.template.exist? themed_partial
      themed_partial
    else
      "#{rad.face.themes_path}/default#{partial}"
    end
  end

  def build_layout layout = nil
    # Configuring
    theme.layout = layout

    # Rendering
    theme.layout_definition['slots'].each do |slot_name, slots|
      slots = Array(slots)
      slots.each do |partial|
        content_for slot_name, render(partial)
      end
    end
  end
end