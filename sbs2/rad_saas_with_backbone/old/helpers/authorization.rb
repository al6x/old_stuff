module Authorization
  def roles_control_links_for user
    links = []

    # Ordered Roles
    %w{member manager}.each do |role|
      unless user.roles.include? role
          if can? "add_#{role}_role"
            links << add_role_link(t("add_#{role}_role"), user, role)
          end
        else
        text = t(role)
        if can? "remove_#{role}_role"
          link = remove_role_link(t("remove_#{role}_role"), user, role)
          links << "#{text} (#{link})"
        else
          links << text
        end
      end
    end

    # Custom Roles
    rad.config.custom_roles.each do |role|
      unless user.roles.include? role
          if can? "add_custom_role"
            links << add_role_link(t(:add_custom_role, role: role), user, role)
          end
        else
        text = t(:custom_role, role: role)
        if can? "remove_custom_role"
          link = remove_role_link(t(:remove_custom_role, role: role), user, role)
          links << "#{text} (#{link})"
        else
          links << text
        end
      end
    end

    # Admin Roles
    unless user.roles.include? 'admin'
        if can? "add_admin_role"
          links << add_role_link(t(:add_admin_role), user, 'admin')
        end
      else
      text = t(:admin)
      if can? "remove_admin_role"
        link = remove_role_link(t(:remove_admin_role), user, 'admin')
        links << "#{text} (#{link})"
      else
        links << text
      end
    end

    links
  end

  protected
    def add_role_link text, user, role
      link_to text, add_role_profile_path(user, role: role, format: :js), method: :post
    end

    def remove_role_link text, user, role
      link_to text, remove_role_profile_path(user, role: role, format: :js), method: :post
    end
end