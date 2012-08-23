module Rad::Http::Controller
  inherit Rad::Controller

  inject :params

  def call method, params = {}
    self.params = params
    public_send method
  end
end