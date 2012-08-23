require 'rad/web/_require'

Rad::Controller::Http::ClassMethods.class_eval do
# Rad::Controller::ForgeryProtector.class_eval do
  alias_method :protect_from_forgery_without_test, :protect_from_forgery
  def protect_from_forgery; end
end