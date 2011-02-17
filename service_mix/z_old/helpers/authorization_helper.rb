module AuthorizationHelper
  def roles_control_links_for user
    links = []
    
    # Ordered Roles
    space_name = Space.current.name
    %w{member manager}.each do |role|
      unless user.roles.include? role
				if can? "add_#{role}_role"
					links << add_role_link(t("add_#{role}_role", :name => Space.current.name), user, role)
				end
		  else
        text = t(role, :name => space_name)
        if can? "remove_#{role}_role"
          link = remove_role_link(t("remove_#{role}_role", :name => Space.current.name), user, role)
          links << "#{text} (#{link})"
        else
          links << text
        end        
      end
    end
          
    # Custom Roles
    Space.current.custom_roles.each do |role|
      unless user.roles.include? role
				if can? "add_custom_role"
					links << add_role_link(t("add_custom_role", :name => Space.current.name, :role => role), user, role)
				end
		  else
        text = t(:custom_role, :name => space_name, :role => role)
        if can? "remove_custom_role"
          link = remove_role_link(t("remove_custom_role", :name => Space.current.name, :role => role), user, role)
          links << "#{text} (#{link})"
        else
          links << text
        end
      end
    end
    
    # Admin Roles
    unless user.roles.include? 'admin'
			if can? "add_admin_role"
				links << add_role_link(t("add_admin_role", :name => Space.current.name), user, 'admin')
			end
	  else
      text = t('admin', :name => Account.current.name)
      if can? "remove_admin_role"
        link = remove_role_link(t("remove_admin_role", :name => Space.current.name), user, 'admin')
        links << "#{text} (#{link})"
      else
        links << text
      end        
    end
    
    links
  end
  
  protected
    def add_role_link text, user, role
      link_to text, add_role_user_path(user, :role => role, :format => :js), :method => :post
    end
    
    def remove_role_link text, user, role
      link_to text, remove_role_user_path(user, :role => role, :format => :js), :method => :post
    end
end