class Models.Menu extends Rad.Model
  defaults:
    layout: 'standard'
    content: null

  view: ->
    @_view ||= Views.Menu.new(model: @)

class Views.Menu extends Rad.View
  events:
    'click ._login'  : '_login'
    'click ._logout' : '_logout'

  initialize: =>
    @model.bind @render

  render: =>
    @el.updateWith $.build('/menu', model: @model, view: @)
    @delegateEvents()
    @

  links: =>
    [user, router, links] = [rad.user(), rad.router(), []]

    if user.hasRole 'global_admin'
      links.add link: router.accountsPath(), name: t('accounts')

    if user.can 'administrate'
      links.add link: router.spacesPath(), name: t('spaces')

    if rad.params().space_name
      links.add link: router.usersPath(), name: t('users')

    links.each (item) ->
      item.active = true if item.link == rad.router().buildUrl(rad.path())

    links

  _login: =>
    url = rad.router().loginPath return_to: rad.url()
    form = @el.find 'form'
    form.attr(method: 'post', action: url).submit()

  _logout: =>
    url = rad.router().logoutPath return_to: rad.url()
    form = $.build 'form', action: url, method: 'post'
    $('body').append form
    form.submit()



# Initialization.
rad.register 'menu', 'page', ->
  Models.Menu.new()