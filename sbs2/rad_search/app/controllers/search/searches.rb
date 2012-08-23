class Searches < ApplicationController
  def search
    partials.show :search
    # show_tags
    
    @query, @current_page = params.q, (params.page.blank? ? 1 : params.page.to_i)
    
    @search = if @query.blank?
      nil
    else
      Models::Item.search do |q|
        q.fulltext @query.to_s, highlight: true
        q.with :space_id, Models::Space.current.id.to_s
        q.with :viewers, Models::User.current.major_roles
        
        q.paginate page: @current_page, per_page: Models::Item::PER_PAGE        
      end
    end
        
    
    # respond_to do |f|
    #   page = params.page || 1
    #   items = self.class.item_model.tagged_with(
    #     selected_tags,
    #     viewers: Models::User.current.major_roles, 
    #     order: 'created_at desc',
    #     dependent: false,
    #     # per_page: 3,
    #     page: page
    #   )
    #         
    #   instance_variable_set "@#{controller_name}", items
    #   @show_paginator = items.size >= Item::PER_PAGE
    #   @next_page_path = send "#{controller_name}_path", page: items.current_page + 1, format: :js
    #   
    #   f.html{
    #     @html_title = t controller_name
    #     render template: "items/index"
    #   }
    #   f.js{render template: "items/index"}
    #   f.json{render json: items}
    # end  
  end 
  
  def resolve_container
    @item = Models::Item.by_param! params.id    
    require_permission :view, @item
    @item.dependent.must_be.true
    container = @item.independent_container
        
    redirect_to send("show_#{container.class.model_name.underscore}_path", container.independent_container)
  end
end