rad.http_router.configure do |c|
  c.alias '/login',    class_name: 'Controllers::Sessions', method: :login
  c.alias '/logout',   class_name: 'Controllers::Sessions', method: :logout

  c.resource :identities,
    class_name: 'Controllers::Identities',
    singleton_methods: [
      :generate_email_confirmation_token,
      :create_user,
      :generate_reset_password_token,
      :reset_password,
      :update_password
    ]

  c.resource :users,    class_name: 'Controllers::Users',
    prefix: :space_name

  c.resource :accounts, class_name: 'Controllers::Accounts'

  c.resource :spaces,   class_name: 'Controllers::Spaces'

  # Mapping `/space` to `SaasApi.read`.
  c.custom_decode do |path, params|
    if path =~ /^\/[^\/]+$/
      params[:id] = path[1..-1]
      [Controllers::SaasApi, :read, path, params]
    end
  end
end