rad.register :theme, depends_on: :face, scope: :cycle do
  Rad::Face::Theme.new
end