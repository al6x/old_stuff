module ItemHelper
  def hidden_fields_for_embedded_form
    return unless embedded?    
    
    %{\
#{hidden_field_tag :container_id, container.to_param}
#{hidden_field_tag :collection, params[:collection] if params[:collection]}
#{hidden_field_tag :view, params[:view] if params[:view]}}
  end
  
  def view_from_params
    return 'embedded' if params[:view].blank?
    
    view = params[:view].must =~ /[0-9a-z_]+/
    "/bag/embedded_views/#{view}"
  end
  
end