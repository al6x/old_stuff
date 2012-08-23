class Rad::Face    
  attr_accessor :themes_path, :theme, :available_themes
  attr_required :themes_path
  def available_themes; @available_themes ||= [] end
  
  def availiable_layouts
    @availiable_layouts ||= {}
  end
end