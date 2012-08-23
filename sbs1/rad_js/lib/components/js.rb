rad.register :js, depends_on: [:html, :controller, :assets] do
  require 'js/gems'
  require 'js/require' 
  
  dir = File.expand_path "#{__FILE__}/../../.."
  rad.assets.paths << "#{dir}/static"
  
  true
end