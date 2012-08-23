module AbstractInterface
  module ViewHelper
    # 
    # Basic
    # 
    def b
      @b ||= AbstractInterface::ViewBuilder.new self
    end
    alias_method :builder, :b

    def themed_resource resource
      "/#{AbstractInterface.plugin_name.should_not_be!(:blank)}/themes/#{current_theme.name}/#{resource}"
    end
    
    def build_layout layout = nil
      # Configuring
      current_theme.layout = layout

      #  Rendering
      current_theme.layout_definition['slots'].each do |slot_name, slots|
        slots = Array(slots)
        slots.each do |partial|
          content_for slot_name do
            render :partial => partial
          end
        end
      end
    end  
      
  end
end