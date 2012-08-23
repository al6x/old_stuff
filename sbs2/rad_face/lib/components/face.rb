rad.register :face, depends_on: [:controller, :template, :js, :web, :assets] do
  require 'face/gems'
  require 'face/require'
  Rad::Face.new
end