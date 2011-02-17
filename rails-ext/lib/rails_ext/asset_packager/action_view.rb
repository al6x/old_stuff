ActionView::Base.class_eval do 
  def merged_javascripts *package_names
    merged_packages 'javascripts', package_names
  end

  def merged_stylesheets *package_names
    merged_packages 'stylesheets', package_names
  end
  
  protected
    # TODO3 cache it
    def merged_packages thetype, package_names
      found_packages = {}
      
      package_names.each do |pname|
        AssetPackager.definitions.each do |path, package_types|
          package_types.each do |type, packages|
            next unless type == thetype
            packages.each do |name, files|
              found_packages[name] = files if name == pname.to_s
            end
          end
        end
      end
      
      package_names.each{|name| found_packages.should! :include, name.to_s}
          
      if AssetPackager.merge_environments.include? Rails.env
        found_packages.collect do |name, files| 
          AssetPackager.filename_for_builded_package thetype, name
        end
      else
        list = []
        found_packages.each do |name, files|
          files.each do |fname|
            fname = if fname =~ /\A\//
              fname
            else
              "/#{fname}"
            end
            list.push fname
          end
        end
        list
      end
    end
end