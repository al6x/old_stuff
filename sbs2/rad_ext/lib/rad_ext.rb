ext_dir = File.expand_path "#{__FILE__}/../.."

rad.after :locale do |locale|
  locale.paths += Dir["#{ext_dir}/locales/*"]
end

rad.after :assets do |assets|
  assets.paths << "#{ext_dir}/assets"
end