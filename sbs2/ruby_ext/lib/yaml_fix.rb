require 'yaml'

begin
  require 'psych'
  YAML::ENGINE.yamler = 'psych'
rescue Exception
  warn "can't load 'psych', the new YAML engine (probably the 'libyaml' is not installed), usng 'sych' a deprecated one, \
there may be some problems with encoding."
end