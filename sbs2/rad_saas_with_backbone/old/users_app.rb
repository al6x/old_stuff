class SaasApp < UserManagement
  inherit Rad::Controller::Captcha

  inherit Rad::Controller::Multitenant

  helper Helpers::Saas::General

  inherit Saas::ControllerHelper

  # protect_from_forgery

  inherit Rad::Controller::Multitenant
end