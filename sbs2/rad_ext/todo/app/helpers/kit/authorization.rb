module Authorization
  def viewers_controls_for object
    object.must_not.be_nil

    all_selected_roles = []
    all_avaliable_roles = []

    # Ordinary Roles
    controls = {
      'member' => link_to(
        t(:member_role),
        viewers_path(object, remove_roles: 'user', add_roles: 'member', format: :js), method: :post
      ),
      'user' => link_to(
        t(:user_role),
        viewers_path(object, remove_roles: 'member', add_roles: 'user', format: :js), method: :post
      ),
    }

    selected_role = Roles.lower_role object.viewers
    selected_role = nil if selected_role == 'manager'
    avaliable_roles = Roles::ORDERED_ROLES.select{|role| role != selected_role and role != 'manager'}
    avaliable_roles = avaliable_roles.collect{|role| controls[role]}

    all_selected_roles << t("#{selected_role}_role") if selected_role
    all_avaliable_roles.push *avaliable_roles

    # Custom Roles
    custom_roles = rad.config.custom_roles
    selected_roles = custom_roles.select{|role| object.viewers.include? role}
    avaliable_roles = custom_roles - selected_roles

    # selected_roles.collect! do |role|
    #   link_to(role, viewers_path(object, remove_roles: role, format: :js), method: :post)
    # end
    avaliable_roles.collect! do |role|
      link_to(role, viewers_path(object, add_roles: role, format: :js), method: :post)
    end

    all_selected_roles.push *selected_roles
    all_avaliable_roles.push *avaliable_roles

    # Clear All
    if all_selected_roles.blank?
      all_selected_roles << t(:only_owner)
    else
      current_roles = object.viewers.select{|r| r != 'manager' and r != "user:#{object.owner_name}"}
      all_avaliable_roles.unshift(
        link_to(
          t(:only_owner),
          viewers_path(object, remove_roles: current_roles.join("\n"), format: :js), method: :post
        )
      )
    end

    [
      %[#{t(:viewers)}: <span class='m_bold'>#{all_selected_roles.join(', ')}</span>],
      %[<span class='m_tiny'>(#{all_avaliable_roles.join(', ')})</span>]
    ]
	end

	def collaborators_controls_for object
    object.must_not.be_nil

    all_selected_roles = []
    all_avaliable_roles = []

    # Ordinary Roles
    controls = {
      'member' => link_to(
        t(:member_role),
        collaborators_path(object, remove_roles: 'user', add_roles: 'member', format: :js), method: :post
      ),
      'user' => link_to(
        t(:user_role),
        collaborators_path(object, remove_roles: 'member', add_roles: 'user', format: :js), method: :post
      ),
    }

    selected_role = Roles.lower_role object.collaborators
    selected_role = nil if selected_role == 'manager'
    avaliable_roles = Roles::ORDERED_ROLES.select{|role| role != selected_role and role != 'manager'}
    avaliable_roles = avaliable_roles.collect{|role| controls[role]}

    all_selected_roles << t("#{selected_role}_role") if selected_role
    all_avaliable_roles.push *avaliable_roles

    # Custom Roles
    custom_roles = rad.config.custom_roles
    selected_roles = custom_roles.select{|role| object.collaborators.include? role}
    avaliable_roles = custom_roles - selected_roles

    # selected_roles.collect! do |role|
    #   link_to(role, collaborators_path(object, remove_roles: role, format: :js), method: :post)
    # end
    avaliable_roles.collect! do |role|
      link_to(role, collaborators_path(object, add_roles: role, format: :js), method: :post)
    end

    all_selected_roles.push *selected_roles
    all_avaliable_roles.push *avaliable_roles

    # Clear All
    if all_selected_roles.blank?
      all_selected_roles << t(:only_owner)
    else
      current_roles = object.collaborators.select{|r| r != 'manager' and r != "user:#{object.owner_name}"}
      all_avaliable_roles.unshift(
        link_to(
          t(:only_owner),
          collaborators_path(object, remove_roles: current_roles.join("\n"), format: :js), method: :post
        )
      )
    end

    [
      %[#{t(:collaborators)}: <span class='m_bold'>#{all_selected_roles.join(', ')}</span>],
      %[<span class='m_tiny'>(#{all_avaliable_roles.join(', ')})</span>]
    ]
	end
end