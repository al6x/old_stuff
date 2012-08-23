rad.register :themes, depends_on: :common_interface do  
  require 'themes/gems'
  require 'themes/require'
  
  rad.face.available_themes.push 'simple_organization'
  (rad.face.availiable_layouts[:simple_organization] ||= []).push :default, :home
  
  rad.configure :web, "#{__FILE__}/../../.." do |c|
    c.template_paths 'app/views'
    c.asset_paths 'app/static'
    c.routes
  end
    
  true
end