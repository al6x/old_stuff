module Saas::Http::UserHelper
  inject :request, :response, :cipher

  def get_user
    login_from_basic_auth || login_from_cookie || login_as_anonymous || \
      raise("You probably don't create Anonymous User!")
  end

  protected
    def login_from_basic_auth
      # TODO3 basic auth
      # authenticate_with_http_controller_basic do |login, password|
      #   User.authenticate_by_password login, password unless login.blank? or password.blank?
      # end
      # username, password = request.credentials
      # User.authenticate_by_password username, password unless username.blank? or password.blank?
    end

    def login_from_cookie
      token = request.params[:user_token] || request.rack_request.cookies['user_token']
      if token
        user_name = begin
          cipher.unsign token
        rescue
          response.delete_cookie 'user_token'
          return nil
        end

        user = Models::User.first name: user_name, state: 'active'
        response.delete_cookie 'user_token' unless user
        user
      end
    end

    def login_as_anonymous
      Models::User.anonymous
    end
    cache_method_with_params_in_production :login_as_anonymous
end