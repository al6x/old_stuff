module AbstractInterface
  module ControllerHelper
    TEMPLATE_EXTENSIONS = ['html.haml', 'html.erb']

    def themed_partial_exist? partial
      partial = partial + "_t"
      
      partial_fname = if pos = partial.index('/')
        partial.clone.insert(pos + 1, '_')
      else
        "_#{partial}"
      end
      
      TEMPLATE_EXTENSIONS.any?{|ext| File.exist? "#{AbstractInterface.themes_dir}/#{current_theme.name}/#{partial_fname}.#{ext}"}
    end    
    cache_with_params! :themed_partial_exist? unless Rails.development?
    
    def themed_partial partial
      if themed_partial_exist? partial
        "/themes/#{current_theme.name}/#{partial}_t"
      else
        "/themes/default/#{partial}_t"
      end
    end
    
    def current_theme
      @current_theme ||= AbstractInterface::Theme.new
    end
  end
end