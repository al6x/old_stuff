class Controllers.Sessions
  # Both login and logout actions use plain HTTP post, not AJAX,
  # because they needs to modify Cookies.

  login: =>
    rad.router().ensureReturnTo()

    showDialog = (model) ->
      rad.dialog().show
        model     : model
        template  : "/sessions/forms/login"
        ok        : (model, dialog) =>
          form = dialog.view().el.find 'form'
          form.attr(method: 'post', action: '').submit()

    model = Models.Identity.new()
    response = rad.server().cachedResponses.deleteProperty(rad.router().loginPath({}))
    raise "no response for :login!" unless response
    if response.success
      rad.router().back()
      rad.application().info t('successfully_logged_in')
    else if response.errors
      model.set response
      showDialog model
    else
      showDialog model

  logout: =>
    rad.router().ensureReturnTo()
    response = rad.server().cachedResponses.deleteProperty(rad.router().logoutPath({}))
    raise "no response for :logout!" unless response
    if response.success
      rad.router().back()
      rad.application().info t('successfully_logged_out')
    else
      form = $.build 'form', action: rad.router().logoutPath(), method: 'post'
      $('body').append form
      form.submit()

rad.register 'sessions', ->
  Controllers.Sessions.new()