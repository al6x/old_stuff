module Rad::ControllerMiscellaneousHelper
  def reload_page
    params = workspace.params
    params.format.must.be_in 'html', 'js'

    keep_flash!
    if params.format == 'js'
      workspace.response.set!(
        status: :ok,
        content_type: Rad::Mime[params.format]
      )
      throw :halt, "window.location.reload();"
    else
      redirect_to request.env["HTTP_REFERER"]
    end
  end
end