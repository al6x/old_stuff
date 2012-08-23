class SaasRouter extends Rad.Router

rad.register 'router', ->
  router = SaasRouter.new()

  router.extend
    persistentParams : ['l'],
    skipParams: ['space_name', 'id']

  # Routes.
  routes =
    identities:
      '/register'              : 'register'
      '/finish_registration'   : 'finishRegistration'
      '/forgot_password'       : 'forgotPassword'
      '/reset_password'        : 'resetPassword'
      '/update_password'       : 'updatePassword'

    sessions:
      '/login'                 : 'login'
      '/logout'                : 'logout'

    users:
      '/:space_name/users'     : 'all'
      '/:space_name/users/:id' : 'read'

    accounts:
      '/accounts'              : 'all'
      '/accounts/:id'          : 'read'

    spaces:
      '/spaces'                : 'all'
      '/spaces/:id'            : 'read'

  routes.each (contrRoutes, controller) ->
    contrRoutes.each (name, route) ->
      router.route route, -> rad.get(controller)[name]()


  # Path methods.
  paths =
    _pathWithReturnTo      : (path, params = {}) ->
      if rad.params().return_to
        params = params.clone().extend return_to: rad.params().return_to
      @buildUrl path, params

    registerPath           : (params = {}) -> @_pathWithReturnTo '/register', params
    finishRegistrationPath : (params = {}) -> @_pathWithReturnTo '/finish_registration', params
    forgotPasswordPath     : (params = {}) -> @_pathWithReturnTo '/forgot_password', params
    resetPasswordPath      : (params = {}) -> @_pathWithReturnTo '/reset_password', params
    updatePasswordPath     : (params = {}) -> @_pathWithReturnTo '/update_password', params

    loginPath    : (params = {}) -> @_pathWithReturnTo '/login', params
    logoutPath   : (params = {}) -> @_pathWithReturnTo '/logout', params

    usersPath    : (params = {}) ->
      space_name = params.space_name || rad.params().space_name
      @buildUrl "/#{space_name}/users", params
    userPath     : (user, params = {}) ->
      space_name = params.space_name || rad.params().space_name
      @buildUrl "/#{space_name}/users/#{user.name}", params

    accountsPath : '/accounts'
    accountPath  : (account, params = {}) -> @buildUrl "/accounts/#{account.name}", params

    spacesPath   : '/spaces'
    spacePath    : (space, params = {}) ->
      @buildUrl "/spaces/#{space.name}", params

    spacesFullPath  : (account, params = {}) ->
      params.host = account.host()
      @buildUrl '/spaces', params
    spaceFullPath   : (account, space, params = {}) ->
      params.host = account.host()
      @buildUrl "/spaces/#{space.name}", params

  paths.each (route, name) ->
    router.namedRoute name, route

  router