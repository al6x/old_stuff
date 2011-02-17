# Converts any non standart fname.yml file in /config folder into FNAME constant with loaded YAML content wrapped into SafeHash.
config_dir = "#{RAILS_ROOT}/config/"
files = Dir.glob("#{config_dir}*.yml")
ignore = ["asset_packages\\.yml", "\\..+\\."].collect{|expr| Regexp.new expr}
files.delete_if{|fname| ignore.any?{|template| template =~ fname}}
files.delete_if{|fname| /^[a-zA-Z0-9_]+\.yml$/ !~ fname.sub(config_dir, '')}

files.each do |fname|
  const = fname.sub(config_dir, '').sub('.yml', '').upcase

  setting = if (data = YAML.load_file(fname)).is_a? Hash
    SafeHash.new data
  else
    data
  end

  Object.const_set const, setting
end