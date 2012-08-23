module Rad::Face::CiViewHelper
  # 
  # Form Buttons
  # 
  def ok_button text = t(:ok)
    submit_tag text, class: 'm_submit_form_or_ajax_form'
  end

  def cancel_button text = t(:cancel)
    link_to text, :back, class: 'm_redirect_back_or_close_dialog'
  end

  # 
  # Custom
  # 
  def tag_cloud tags, classes, &block
    return if tags.empty?

    max_count = tags.sort{|a, b| a.count <=> b.count}.last.count.to_f

    tags.sort{|a, b| a.name <=> b.name}.each do |tag|
      index = ((tag.count / max_count) * (classes.size - 1)).round
      block.call tag, classes[index]
    end
  end
  
  
  # 
  # Attachments
  # 
  def attachments_tag name, value = [], options = {}
    value = value.collect{|h| h.to_openobject}
    render '/face/attachments_tag', object: options.merge(name: name, value: value).to_openobject
  end


  # 
  # Folder
  # 
  # params = {
  #   l: I18n.locale,
  # }
  # 
  # opt = {
  #   upload_url: item_files_path(folder),
  #   view: 'folder_thumb',
  #   select_files: t(:select_files),
  # }
  # def build_files_uploader_for params, opt
  #   raise 'update me with rad.config and with rad.cookies'
  #   session_key = ActionController::Base.session_options['key']
  #   
  #   params = {
  #     session_key => cookies[session_key]
  #   }.merge(params)
  #   
  #   "new FilesUpload(#{params.to_json}, #{opt.to_json});"    
  # end
end