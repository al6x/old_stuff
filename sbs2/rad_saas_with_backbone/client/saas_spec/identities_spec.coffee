describe "Identities", ->
  beforeEach ->
    withSaas @

  it "should register users", ->
    rad.setUser factory.create('anonymous')

    @router.goToRegisterPath()
    client.text().should contain: 'Signup'

    @server.stub '/identities/generate_email_confirmation_token', {}
    client.click 'Ok'
    client.text().should contain: 'follow the link sent to Your email'

  it "shoud finish registration", ->
    rad.setUser factory.create('anonymous')

    @router.goToFinishRegistrationPath()
    client.text().should contain: 'Signup'

    @server.stub '/identities/create_user', {}
    client.click 'Ok'
    rad.path().should contain: '/login'

  it "should restore forgotten password", ->
    rad.setUser factory.create('anonymous')

    @router.goToForgotPasswordPath()
    client.text().should contain: 'Restore password'

    @server.stub '/identities/generate_reset_password_token', {}
    client.click 'Ok'
    client.text().should contain: 'Link for password restoration has been sent to Your email'

  it "should reset password", ->
    rad.setUser factory.create('anonymous')

    @router.goToResetPasswordPath()
    client.text().should contain: 'Reset password'

    @server.stub '/identities/reset_password', {}
    client.click 'Ok'
    rad.path().should contain: '/login'

  it "should update password", ->
    rad.setUser factory.create('user')

    @router.goToUpdatePasswordPath()
    client.text().should contain: 'Update password'

    @server.stub '/identities/update_password', {}
    @server.stub '/users/alex', factory.create('user')
    client.click 'Ok'
    client.text().should contain: "Password updated"