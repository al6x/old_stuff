module Rad::Remote::RemoteController
  inherit Rad::Filters

  inject :workspace, :logger

  def params
    workspace.params
  end
end