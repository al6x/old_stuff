require 'abstract_interface/haml_builder'
require 'abstract_interface/model_stub'
require 'abstract_interface/view_helper'
require 'abstract_interface/support'

ActionController::Base.class_eval do
  include AbstractInterface::ControllerHelper
  helper AbstractInterface::ViewHelper
  
  helper_method :themed_partial_exist?, :themed_partial, :current_theme
end

ActionView::Base.field_error_proc = lambda do |html_tag, instance|
  html_tag
end

module AbstractInterface
  class << self
    attr_accessor :plugin_name
    attr_accessor :layout_configurations_dir
    
    def generate_helper_methods *args
      AbstractInterface::ViewBuilder.generate_helper_methods *args
    end
    
    def available_themes; @available_themes ||= [] end
    
    # Templates that should be wrapped if it doesn't defined for current theme
    # def dont_wrap_into_placeholder; @dont_wrap_into_placeholder ||= Set.new end
    
    # TODO 3 don't cache it becouse there's a lots of text data that will be reside in memory.
    def theme_metadata theme
      metadata = {}
      fname = "#{AbstractInterface.themes_dir}/#{theme}/metadata.rb"
      if File.exist? fname
        code = File.read fname
        metadata = eval code
        metadata.should! :be_a, Hash        
      end
      metadata.to_openobject
    end
    cache_with_params! :theme_metadata unless Rails.development?
    
    def themes_dir
      "#{RAILS_ROOT}/vendor/plugins/#{AbstractInterface.plugin_name.should_not_be!(:blank)}/app/views/themes"
    end
    
    def layouts_defined?
      !!layout_configurations_dir
    end
    
    def layout_definitions theme
      fname = "#{layout_configurations_dir.should_not_be!(:empty)}/#{theme}.yml"
      File.should! :exist?, fname
      lds = YAML.load_file(fname)
      validate_layout_definition!(lds, theme)
      lds
    end
    cache_with_params! :layout_definitions unless Rails.development?
    
    protected
      def validate_layout_definition! lds, theme
        lds.should! :be_a, Hash
        unless lds.include?('default')
          raise "No 'default' layout definition for '#{theme}' Theme (there always should be definition for 'default' layout)!"
        end
        lds.each do |theme_name, ld|
          ld.should! :be_a, Hash
          ld.should! :include, 'layout_template'
          ld.should! :include, 'slots'
          ld['slots'].should! :be_a, Hash
        end
      end
  end
    
end

Rails.development{RailsExt.create_public_symlinks!} # rails_ext.css, rails_ext.js in development mode