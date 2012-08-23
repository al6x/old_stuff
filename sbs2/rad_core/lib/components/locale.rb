rad.register :locale do
  Rad::Locale.new
end
rad.after :locale do |locale|
  locale.current = locale.default
end