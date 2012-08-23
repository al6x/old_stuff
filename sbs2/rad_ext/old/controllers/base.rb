class Base
  inherit Rad::Controller::Http

  protected
    allow_get_for %()

    inherit Rad::Controller::Localized

    before :prepare_current_user

    inherit Rad::Controller::Authorized

    helper Helpers::Kit::NavigationHelper

    #
    # User Error
    #
    def catch_user_error
      begin
        yield
      rescue UserError => e
        msg = e.message || ""
        flash.error = msg
        flash.sticky_error = msg

        if request.xhr? or params.format == 'js'
          render inline: %(rad.error("#{msg.js_escape.html_escape}");), layout: false
        else
          dont_persist_params{redirect_to default_path}
        end
      end
    end
    around :catch_user_error


    #
    # Interface Builder
    #
    def set_theme
      theme.name = params.theme || rad.face.theme # || 'default'
    end
    before :set_theme
end