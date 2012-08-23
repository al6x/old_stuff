rad.register :assets do
  rad_dir = File.expand_path "#{__FILE__}/../../.."
  Rad::Assets.new.tap{|a| a.paths << "#{rad_dir}/assets"}
end