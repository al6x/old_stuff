module Rad::Web
  module Processors
  end
end

%w(
  _controller_miscellaneous_helper

  _router/abstract_routing_helper
  _router/view_routing_helper
  _router/controller_routing_helper

  _ajax_helper
  _ensure_no_www
  _protect_from_forgery
).each{|f| require "rad/web/#{f}"}


# View helpers
# [
#   Rad::Html::HtmlHelper,
#   Rad::Router::CoreRoutingHelper, Rad::ViewRoutingHelper
# ].each do |helper|
#   Rad::Template::Context.inherit helper
# end

# Controller helpers
# [
#   Rad::Html::FlashHelper,
#   Rad::Router::CoreRoutingHelper, Rad::ControllerRoutingHelper,
#   Rad::ControllerMiscellaneousHelper
# ].each do |helper|
#   Rad::Controller::Abstract.inherit helper
# end