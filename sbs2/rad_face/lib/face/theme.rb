class Rad::Face::Theme      
  def name; @name || 'default' end    
  def name= name
    # lots of other properties depends on :name, so we need to clean all of them if we change name
    clear
    @name = name.to_sym if name.present?
  end
  
  attr_writer :layout
  def layout; @layout || 'default' end            
  
  def layout_template
    @layout_template || layout_definition['layout_template'] || 'default'
  end      

  def layout_template= layout_template
    path = "#{rad.face.themes_path}/#{name}/layout_templates/#{layout_template}"      
    @layout_template = (layout_template and rad.template.exist?(path)) ? layout_template : 'default'
  end      
  
  def layout_definition
    self.class.layout_definition(name, layout) || self.class.layout_definition(name, 'default') || {}
  end

  protected
    def clear
      @layout_config, @layout_template, @layout = nil
    end
  
  class << self
    def layout_definition theme, layout
      path = "#{rad.face.themes_path}/#{theme}/layout_definitions/#{layout}.yml"
      files = Rad::Environment::FilesHelper.find_files(path, rad.template.paths)
      raise "multiple layout configs '#{layout}' for '#{theme}' theme!" if files.size > 1        
      if absolute_path = files.first
        YAML.load_file(absolute_path).tap do |definition|
          definition.must.be_a Hash
          definition.must.include 'layout_template'
          definition.must.include 'slots'
          definition['slots'].must.be_a Hash
        end
      else
        nil
      end
    end
    cache_method_with_params_in_production :layout_definition
  end
end