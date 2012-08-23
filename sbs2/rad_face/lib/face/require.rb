require 'rad'

class Rad::Face
end

%w(
  support
  html_open_object
  theme
  haml_builder
  themed_form_helper
  view_builder
  view_helper
  face
).each{|f| require "face/#{f}"}

Rad::Template::Context.inherit Rad::Face::ViewHelper
Rad::Controller::Abstract.inject theme: :theme