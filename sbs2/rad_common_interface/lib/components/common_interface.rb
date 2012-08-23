rad.register :common_interface, depends_on: :face do  
  require 'common_interface/gems'  
  require 'common_interface/require'
  
  # config
  rad.face.available_themes << :default
  
  rad.configure :web, "#{__FILE__}/../../.." do |c|
    c.locales
    c.routes
    c.template_paths 'app/views'
    c.asset_paths 'app/static'
  end  
  
  true
end