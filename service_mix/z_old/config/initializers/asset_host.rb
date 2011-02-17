Rails.production do
  ActionController::Base.asset_host = "assets%d.#{SETTING.master_domain!}"
end
