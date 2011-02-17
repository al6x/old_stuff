crystal.initialize_plugin :web, __FILE__.parent_dirname do |c|
  c.routes
  c.locales
  c.autoload %w(controllers helpers models)
end