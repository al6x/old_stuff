###
rad.require '/rad/spec.coffee'
###

global.withSaas = (context) ->
  rad.beginScope 'page'

  rad.setUrl '/'
  rad.setPath '/'
  rad.setParams {}

  rad.application().clear()
  rad.application().view().render()

  rad.server().clear()

  [context.server, context.router] = [rad.server(), rad.router()]

# Models.
factory.define 'anonymous', Models.User, (user, create) ->
  name = "anonymous"
  user.id = name if create
  user.extend
    name  : name
    role  : 'user'
    roles : ['anonymous', 'user', "user:anonymous"]
    permissions: []

factory.define 'user', Models.User, (user, create) ->
  name = "user_#{factory.next()}"
  user.id = name if create
  user.extend
    name  : name
    role  : 'user'
    roles : ['registered', 'user', "user:#{name}"]
    permissions: []

factory.define 'member', Models.User, (user, create) ->
  name = "member_#{factory.next()}"
  user.id = name if create
  user.extend
    name  : name
    role  : 'member'
    roles : ['registered', 'user', 'member', "user:#{name}"]
    permissions: []

factory.define 'admin', Models.User, (user, create) ->
  name = "admin_#{factory.next()}"
  user.id = name if create
  user.extend
    name  : name
    role  : 'admin'
    roles : ['registered', 'user', 'member', 'manager', 'admin', "user:#{name}"]
    permissions: [
      "administrate",
      "manage_admins",
      "manage_managers",
      "manage_members",
    ]

factory.define 'global_admin', Models.User, (user, create) ->
  name = "admin_#{factory.next()}"
  user.id = name if create
  user.extend
    name  : name
    role  : 'admin'
    roles : ['registered', 'user', 'member', 'manager', 'admin', 'global_admin', "user:#{name}"]
    permissions: [
      "administrate",
      "manage_admins",
      "manage_managers",
      "manage_members",
    ]

factory.define 'account', Models.Account, (account, create) ->
  account.name = "account-#{factory.next()}"
  account.id = account.name if create

factory.define 'space', Models.Space, (space, create) ->
  space.extend
    name     : "space#{factory.next()}"
    language : 'en'
    theme    : 'default'
  space.id = space.name if create