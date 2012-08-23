module ItemHelper

  #
  # Tag Selector
  #
  def add_tag name
    (selected_tags + [name]).join('-')
  end

  def remove_tag name
    list = (selected_tags - [name]).join('-')
    return nil if list.empty?
    list
  end

  def render_item_tags item
    # Tags

    tags = item.tags.topic.collect{|tag_name| tag_link tag_name}

    # Visibility
    viewers = item.minor_viewers
    owner_role = "user:#{item.owner_name}"
    viewers = viewers.select{|role| role != owner_role}
    if viewers.blank? # visible only to owner
      tags << tag(:div, t(:owner_visibility), class: :m_owner_visibility)
    else
      viewers.each do |role|
        if role == 'user'
          # don't show public visibility
        elsif role == 'member'
          tags << tag(:div, t(:member_visibility), class: :m_member_visibility)
        else
          tags << tag(:div, role, class: :m_custom_visibility)
        end
      end
    end

    tags
  end

  def tag_link tag_name, count = nil
    # link = if current_item and current_item.is_a?(Selector)
    #   build_url(action_name, _tags: tag_name)
    # else
    #   items_path(_tags: tag_name)
    # end

    link = items_path(_tags: tag_name)

    if count
      link_to(tag_name, link, title: t(:tags_count, count: count))
    else
      link_to(tag_name, link)
    end
  end

  def render_item_details item, opt = {}
    skip = Array(opt[:skip])

    item.must.be_a Models::Item
    details = []
    details << item.created_at.time_ago_in_words unless skip.include? :created_at
    details << t(:created_by, owner: link_to(item.owner_name, user_path(item.owner_name))) unless skip.include? :owner
    details << t(:comments_count, count: item.comments_count) if item.comments_count > 0 and !skip.include?(:comments)
    details
  end

  def form_title_for item
    # return if embedded? or !item.new_record?
    return unless item.new_record?

    model_name = item.class.alias.underscore
    t "create_#{model_name}"
  end

  def common_fields_for_item form, opt = {}, &extra_fields
    object = form.model #instance_variable_get '@object'
    skip = Array(opt[:skip])

    html = ""
    html << form.text_field(:topics_as_string, label: t(:tags)) unless skip.include? :tags
    more = ""
    unless skip.include? :slug
      slug_opt = object.new_record? ? {label: t(:slug)} : {label: t(:slug), description: t(:slug_description)}
      # more << form.text_field(:slug, (object.new_record? ? '' : object.slug), slug_opt)
      more << form.text_field(:slug, slug_opt)
    end
    more << capture(&extra_fields) if extra_fields
    html << b.more(id: "form_for_#{object.class.name.underscore}", name: t(:show_more), 'content' => more)
    # if extra_fields
    #   html << capture{b.more(id: "form_for_#{object.class.name.underscore}", name: t(:show_more), &extra_fields)}
    # else

    if extra_fields
      concat html
    else
      html
    end
  end

  def item_layout_selector
    current = (@model.layout || :default).to_sym
    layouts = rad.face.availiable_layouts[theme.name] || []
    layouts << current unless layouts.include? current

    html_options = {class: 'm_autosubmit_on_change', 'data-action' => layout_path(@model, format: :js), 'data-remote' => true}
    "#{t(:layout)}: #{select_tag(:layout, current, layouts.collect{|l| [l, l]}, html_options)}"
  end
end