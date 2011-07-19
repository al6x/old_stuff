rad.conveyors.web do |web|
  web.use Rad::Controller::Processors::ControllerCaller
end