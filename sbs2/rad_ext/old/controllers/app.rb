class App < Controllers::BaseApp
  inherit Rad::Controller::Captcha

  rad.extension :kit_app, self
end