module ServiceMix
  module WigetHelper
    def sm_used?
      !!@sm_used
    end
    
    # def sm_topic resource, params, visual_params
    #   resource.id.should_not! :be_nil
    #   
    #   data = {
    #     :resource => {
    #       :resource_id => resource.id, 
    #       :resource_type => resource.class.name,
    #     },
    #   }
    # 
    #   js = wiget_initialization_script
    #   js << %{new Commentable(#{data.to_json}, #{visual_params.to_json})}
    #   javascript_tag js
    # end
    # 
    # def sm_vote resource, params, visual_params
    #   resource.id.should_not! :be_nil
    #   
    #   params = {:value => 1}.merge params
    # 
    #   data = {
    #     :resource => {
    #       :resource_id => resource.id, 
    #       :resource_type => resource.class.name,
    #     },
    # 
    #     :vote => {
    #       :value => params[:value]
    #     }
    #   }
    # 
    #   js = wiget_initialization_script_script
    #   js <<  %{new Votable(#{data.to_json}, #{visual_params.to_json})}
    #   javascript_tag js
    # end
    
    def folder_wiget folder, opt = {}      
      params = opt[:params] || {}
      params[:refresh_url].should_not_be! :blank
      params[:folder_id] = folder.id.to_s
      
      secure_params = {
        :folder => {
          :folder_id => folder.id.to_s, 
          :folder_type => folder.class.name,
        }
      }
      
      visual_params = opt[:visual_params] || {}

      %{\
#{wiget_initialization_script}
new Folder(
  #{params.to_json}, 
  '#{build_secure_params secure_params}',
  #{visual_params.to_json}
)}
    end
      
    private
      def wigets_initialization_parameters
        @wigets_initialization_parameters.should_not!(:be_nil)
      end
    
      def build_secure_params secure_params
        secure_params = {
          :service => SETTING.service!,
          :authenticity_token => form_authenticity_token,
          # :api_key => SETTING.api_key!
        }.merge(wigets_initialization_parameters[:secure_params]).merge(secure_params)
        
        ServiceMix.encrypt secure_params
      end
    
      def wiget_initialization_script
        return "" if sm_used?
        @sm_used = true
        
        params = wigets_initialization_parameters[:params]
        
        # params = {
        #   :l => SETTING.default_locale(nil),
        #   :authenticity_token => form_authenticity_token
        # }.merge params

        flash_params = if params.delete :flash
          session_key = ActionController::Base.session_options[:key]
          {
            # :authenticity_token => form_authenticity_token,
            session_key => cookies[session_key]
          }
        else
          {}
        end
        
        js = <<DOC
sm = new SM(
  #{params.to_json}, 
  {#{flash_params.to_a.collect{|k, v| "'#{k}': '#{v}'"}}}
);
DOC
        return js
      end
    
      def service_url path, params = {}
        # params[:host], params[:port] = SETTING.master_domain!, SETTING.port!
        path.first.should! :==, '/'
        custom_url_for "/sm/wigets#{path}", params
      end
    
      def custom_url_for path, params = {}
        host, port = params.delete(:host), params.delete(:port)
    
        url = if host
          "http://#{host}" + ((port and port.to_s != "80") ? ":#{port}" : "")
        else
          ""
        end
    
        url += path
        unless params.empty?
          data = params.to_a.collect{|tuple| "#{tuple[0]}=#{CGI.escape((tuple[1] || '').to_s)}"}.join('&')
          url += "?#{data}"
        end
    
        return url
      end
  end
end