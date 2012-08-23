saas_dir = "#{__FILE__}/../../.."

rad.register :saas do
  rad.configure saas_dir do |c|
    c.locale_paths '/server/locales'
    c.asset_paths '/client'
    c.template_paths '/client/templates'
    c.load_paths '/server', true
  end
  Saas.new
end

rad.after :saas do
  require 'saas/http/routes'
end