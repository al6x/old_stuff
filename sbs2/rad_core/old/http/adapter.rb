class Adapter
  inject :conveyors

  def call env, workspace = {}, &block
    # result, opt = nil, opt.to_openobject
    workspace = conveyors.web.call(
      {env: env, response: Rad::Http::Response.new}.merge(workspace),
      &block
    )

    response = workspace.response.must.be_defined
    result = response.finish

    result
  end
  # synchronize_method :call

  # def mock_call env = {}, workspace = {}, &block
  #   env['PATH_INFO'] ||= '/'
  #   env['rack.input'] ||= StringIO.new
  #
  #   call env, workspace, &block
  # end
end