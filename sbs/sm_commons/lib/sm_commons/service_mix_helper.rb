module ServiceMixHelper
  
  # [
  # ['BOS-Tec', '/'],
  # ['Lab', lab_path]
  # ]
  # 
  def logo
    return [] if @logo.blank?    
    logo = @logo.is_a?(Array) ? @logo : [@logo]
    logo.size.should! :be_in, 1..2
    
    # Delete default space name if there is
    logo = logo.select do |item|
      if item.is_a?(Array)
        !Space.default?(item[0])
      else
        !Space.default?(item)
      end
    end

    logo.collect{|item| item.is_a?(Array) ? link_to(item.first, item.last) : item}
  end
  
  # [
  # ['Users', user_path],
  # ['Roles']
  # ]
  #
  def breadcrumb
    Array(@breadcrumb)
	end
	
	
  # def visibility_selector_for object
  #   object.should_not! :be_nil
  #   object.should! :be_a, MongoMapper::Acts::AuthorizedObject
  #   field_name = "#{object.class.model_name.underscore}[visibility_as_string]"
  #   html = ""
  #   Role::VISIBILITY_ROLES.each do |role|     
  #     checked = role == object.visibility_as_string     
  #     html += radio_button_tag field_name, role, checked
  #     html += label_tag "#{field_name}_#{role}", t("#{role}_role")
  #     html += "\n"
  #   end
  #   html
  # end
end

ActionController::Base.class_eval do
  helper ServiceMixHelper
end