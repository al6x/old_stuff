# Identity.
class Models.Identity extends Rad.RemoteModel
  @resource: '/identities'

  generateEmailConfirmationToken: (callback) ->
    @call '/generate_email_confirmation_token', attributes: true, callback

  createUser: (token, callback) ->
    @call '/create_user', token: token, attributes: true, callback

  generateResetPasswordToken: (callback) ->
    @call '/generate_reset_password_token', attributes: true, callback

  resetPassword: (token, callback) ->
    @call '/reset_password', token: token, attributes: true, callback

  updatePassword: (callback) ->
    @call '/update_password', attributes: true, callback

# User.
class Models.User extends Rad.RemoteModel
  @resource: -> "/#{rad.params().space_name}/users"

  anonymous: -> @roles.include 'anonymous'
  registered: -> !@anonymous()

  can: (operation) -> @permissions.include operation

  hasRole: (role) -> @roles.include role

  addRole: (role, callback) ->
    @call "/#{@id}/add_role", role: role, callback

  deleteRole: (role, callback) ->
    @call "/#{@id}/delete_role", role: role, callback

# Account.
class Models.Account extends Rad.RemoteModel
  @resource: -> "/accounts"

  defaults:
    enabled : true
    domains : []
    spaces  : []

  host: -> @domains.first()

# Space.
class Models.Space extends Rad.RemoteModel
  @resource: -> "/spaces"