class Controllers.Identities
  register: =>
    rad.router().ensureReturnTo()
    @_show 'register', (model, dialog) =>
      model.generateEmailConfirmationToken ->
        if model.valid()
          dialog.close()
          msg = t 'email_verification_code_sent', email: model.email
          rad.application().info msg, sticky: true

  finishRegistration: =>
    rad.router().ensureReturnTo()
    @_show 'finishRegistration', (model, dialog) =>
      model.createUser rad.params().token, =>
        if model.valid()
          dialog.close()
          rad.router().goToLoginPath()
          rad.application().info t('successfully_registered'), sticky: true

  forgotPassword: =>
    rad.router().ensureReturnTo()
    @_show 'forgotPassword', (model, dialog) =>
      model.generateResetPasswordToken =>
        if model.valid()
          dialog.close()
          msg = t 'successfully_reset_password', email: model.email
          rad.application().info msg, sticky: true

  resetPassword: =>
    rad.router().ensureReturnTo()
    @_show 'resetPassword', (model, dialog) =>
      model.resetPassword rad.params().token, =>
        if model.valid()
          dialog.close()
          rad.router().goToLoginPath()
          rad.application().info t('password_restored'), sticky: true

  updatePassword: =>
    @_show 'updatePassword', (model, dialog) =>
      model.updatePassword =>
        if model.valid()
          dialog.close()
          rad.application().info t('password_updated'), sticky: true

  _show: (form, success) ->
    model = Models.Identity.new()
    rad.dialog().show model, "/identities/forms/#{form}", success

rad.register 'identities', ->
  Controllers.Identities.new()