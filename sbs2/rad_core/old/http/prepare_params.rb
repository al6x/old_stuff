rad.http

#
# Outdated, Rack does this by themself, keeping it just in case.
#
class PrepareParams < Rad::Conveyors::Processor
  def call
    workspace.env.must.be_defined
    workspace.request = Rad::Http::Request.new(workspace.env)
    workspace.path = workspace.request.path
    params = workspace.params = Rad::Conveyors::Params.new(workspace.request.params)

    if params.json?
      json_params = JSON.load params.delete('json')
      json_params.must.be_a Hash
      json_params.keys.each do |k|
        logger.warn "RAD parameter :#{k} will be overwriden from JSON!" if params.include?(k)
      end
      params.merge! json_params
    end
    next_processor.call
  end
end