def rails_require arg
  files = arg.is_a?(Array) ? arg : [arg]
  files.each{|file| Rails.development? ? load(file) : require(file)}
end