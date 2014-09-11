class Module	
  def localization lang
    list, resource = [], "#{lang}.#{RubyExt::Localization::RESOURCE_EXTENSION}"
    self_ancestors_and_namespaces do |klass|
    	if RubyExt::Resource.resource_exist? klass, resource
				list << RubyExt::Resource.resource_get(klass, resource)
			end
    end
    return list.reverse.inject(:merge)
  end
end