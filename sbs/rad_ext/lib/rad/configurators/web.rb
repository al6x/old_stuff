class Web < Abstract      
  def asset_paths *relative_paths
    relative_paths = relative_paths.first if relative_paths.first.is_a? Array
    relative_paths.each do |relative_path|
      path = "#{dir}/#{relative_path}"
      rad.assets.paths << path unless rad.assets.paths.include? path
    end
  end
  
  def load_paths *relative_paths
    relative_paths = relative_paths.first if relative_paths.first.is_a? Array
    relative_paths.each do |relative_path|
      path = "#{dir}/#{relative_path}"
      $LOAD_PATH << path unless $LOAD_PATH.include? path
    end
  end
  
  def template_paths *relative_paths
    rad.template
    
    relative_paths = relative_paths.first if relative_paths.first.is_a? Array
    relative_paths.each do |relative_path|
      path = "#{dir}/#{relative_path}"
      rad.template.paths << path unless rad.template.paths.include? path
    end
  end
  
  def autoload_paths *relative_paths
    relative_paths = relative_paths.first if relative_paths.first.is_a? Array        
    relative_paths.each{|d| autoload_dir "#{dir}/#{d}", true}
  end      
end