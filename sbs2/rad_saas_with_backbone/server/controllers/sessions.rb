class Controllers::Sessions < Controllers::Saas
  def login
    if rad.request.rack_request.post?
      if user = Models::User.authenticate_by_password(params[:name], params[:password])
        rad.response.set_cookie 'user_token', \
          value: rad.cipher.sign(user.name),
          expires: Time.now + 2 * 7 * 24 * 3600 * 40 # TODO remove me

        rad.user = user
        user.to_rson(:public).merge success: true
      else
        {name: params[:name], errors: {base: [t(:invalid_login)]}}.to_rson
      end
    else
      {}
    end
  end

  def logout
    if rad.request.rack_request.post?
      rad.response.delete_cookie 'user_token'
      rad.user = Models::User.anonymous
      {success: true}
    else
      {}
    end
  end
end