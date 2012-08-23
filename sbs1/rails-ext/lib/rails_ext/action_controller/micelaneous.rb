# Shortcut for :unprocessable_entity, head(:failed) instead of head(:unprocessable_entity)
ActionController::StatusCodes::SYMBOL_TO_STATUS_CODE[:failed] = 422

# 
# url_for, used to generate url_for for string path with options and with default_url_options
# 
ActionController::Base.class_eval do
  protected  
    # 
    # link_to
    # 
    def link_to text, uri
      %{<a href="#{uri}">#{text}</a>}
    end  
  
    # 
    # Bunch of small actions
    # 
    def render_action action_or_template    
      args = action_or_template.to_s.split('/')      
      args.size.should! :be_in, 1..2
      if args.size == 1
        action = args.first
        @the_action = action.to_sym
        render :action => 'actions'
      else
        path, action = args
        @the_action = action.to_sym
        render :template => "#{path}/actions"
      end       
    end
    
    def the_action; @the_action end
    helper_method :the_action    
  
  
    # 
    # Url from String Path
    # 
    def url_for_path path, options = {}
      unless options.delete :no_prefix
        url = ActionController::Base.relative_url_root + path
      else
        url = path.dup
      end
      
      options = default_url_options.merge options
      
      # Delete 'nil' parameters
      to_delete = []
      options.each{|k, v| to_delete << k if v.nil?}
      to_delete.each{|k| options.delete k}
      
      host = options.delete(:host) || options.delete('host')
      port = options.delete(:port) || options.delete('port')
      
      delimiter = path.include?('?') ? '&' : '?'
      
      url << "#{delimiter}#{options.to_query}" unless options.empty?
      url._url_format = options[:format] if options[:format] # hack for links with ajax support
      url
      
      if host.blank?
        url
      else
        %{http://#{host}#{":#{port}" unless port.blank?}#{url}}
      end
    end
    helper_method :url_for_path
  
   
    # 
    # User Error
    # 
    def catch_user_error
      begin
        yield
      rescue UserError => e
        flash[:error] = e.message
        flash[:sticky_error] = e.message
        do_not_persist_params do
          if request.xhr? or request.format == 'js'
            render :inline => "", :layout => 'application'
          else
            redirect_to default_path
          end          
        end
      end
    end
    around_filter :catch_user_error
        
    # 
    # enshure domain has www. except if there's custom subdomain
    # 
    def ensure_no_www
      uri = Addressable::URI.parse request.url
      if uri.host =~ /^www\./
        uri.host = uri.host.sub(/^www\./, '')
        redirect_to uri.to_s
      end
    end        
  
  class << self
    
    def prepare_model aclass, opt = {}
      id = opt.delete(:id) || :id
      variable = opt.delete(:variable) || aclass.model_name.underscore
      finder = opt.delete(:finder) || :find!
      
      method = "prepare_#{variable}"
      define_method method do
        model = aclass.send finder, params[id]
        instance_variable_set "@#{variable}", model
      end
      before_filter method, opt
    end
  end
end