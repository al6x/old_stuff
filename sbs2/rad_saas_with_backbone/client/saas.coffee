###
Libraries.

  rad.require '/rad.coffee'
  rad.require '/vendor/jgrowl/jgrowl.js'

Models.

  rad.require '/saas/models.coffee'

Wigets.

  rad.require '/saas/router.coffee'

  rad.require '/saas/locales.coffee'
  rad.require '/saas/application.coffee'
  rad.require '/saas/notifications.coffee'
  rad.require '/saas/dialog.coffee'
  rad.require '/saas/menu.coffee'
  rad.require '/saas/paginator.coffee'

Controllers.

  rad.require '/saas/identities.coffee'
  rad.require '/saas/sessions.coffee'
  rad.require '/saas/users.coffee'
  rad.require '/saas/accounts.coffee'
  rad.require '/saas/spaces.coffee'
###

# Localization.
rad.router().bind 'route:before', -> rad.locale().current = rad.params().l

# Make static links dynamic.
$('a').live 'click', ->
  e = $ @
  [href, root] = [e.attr('href'), rad.router().root]
  if href and href[0..(root.size() - 1)] == root
    rad.router().navigate href
    false

# User.
rad.register 'user'
rad.after 'user', (user) -> logger.info "log in as #{user.name}"