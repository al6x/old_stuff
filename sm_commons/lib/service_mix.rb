module ServiceMix
  class << self
    RELATIVE_URL_ROOT = '/sm'
    
    # def encrypt message
    #   if Rails.production?
    #     encryptor = ActiveSupport::MessageEncryptor.new SETTING.api_key!
    #     encryptor.encrypt message
    #   else
    #     message.to_json
    #   end
    # end
    # 
    # def decrypt message
    #   begin
    #     if Rails.production?
    #       encryptor = ActiveSupport::MessageEncryptor.new SETTING.api_key!
    #       encryptor.decrypt message
    #     else
    #       JSON.parse message
    #     end
    #   rescue ActiveSupport::MessageEncryptor::InvalidMessage
    #     raise_user_error "Invalid encrypted Message!"
    #   end
    # end
    
    def relative_url_root      
      if RELATIVE_URL_ROOT == ActionController::Base.relative_url_root
        ""
      else
        RELATIVE_URL_ROOT
      end
    end
    
    def require_assets
      return if @assets_required
      @assets_required = true
      
      
      dir = File.dirname __FILE__
      AssetPackager.add "#{dir}/asset_packages.yml", "#{dir}/public"
      
  
      config = YAML.load File.read("#{File.dirname __FILE__}/service_mix/asset_packages.yml")
      
      asset_yml = Synthesis::AssetPackage.send :class_variable_get, '@@asset_packages_yml'
      
      config.each do |type, packages|
        asset_yml[type].concat packages
      end
    end
  end
end