module AbstractInterface 
  class Theme
    attr_writer :name, :layout_template, :layout    
    def name; @name || 'default' end    
    def layout; @layout || 'default' end
    
    def layout_template
      if @layout_template
        # Check if this template exists
        exists = layout_definitions.any?{|layout_name, ld| ld['layout_template'] == @layout_template}
        exists ? @layout_template : 'default'
      else
        layout_definition['layout_template'] || 'default'
      end
    end
    
    def layout_definition      
      layout_definitions[layout] || layout_definitions['default'] || {}
    end
    
    def layout_definitions
      if AbstractInterface.layouts_defined?
        AbstractInterface.layout_definitions(name)
      else
        {}
      end
    end
    
    def available_layouts_names
      layout_definitions.keys
    end

    def metadata
      AbstractInterface.theme_metadata(name)
    end
  end
end