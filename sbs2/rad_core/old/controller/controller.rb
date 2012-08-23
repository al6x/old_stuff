RSpec.configure do |config|
  config.before :all do |context|
    self.response, self.workspace = nil
  end
end

rspec do
  attr_accessor :response, :workspace

  def ccall klass, method, params = {}, workspace_variables = {}, &block
    self.response = Rad::Http::Response.new
    workspace_variables = {
      class: klass, method_name: method, params: Rad::Conveyors::Params.new(params), response: response
    }.merge(workspace_variables)

    if block
      rad.conveyors.web.call workspace_variables do |c|
        self.workspace = rad.workspace

        block.call c
      end
    else
      self.workspace = rad.conveyors.web.call workspace_variables
    end

    if klass and klass.name =~ /Http/
      response.content_type.must.be_present
      response.status.must.be_present
    end

    workspace.content
  end

  def self.with_abstract_controller
    before do
      rad.controller

      rad.conveyors.web do |web|
        web.use Rad::Controller::Processors::ControllerCaller
      end
    end
    after{rad.reset :conveyors}
  end
end

Rad::Controller::Abstract.class_eval do
  def render_ok
    render inline: 'ok'
  end
end