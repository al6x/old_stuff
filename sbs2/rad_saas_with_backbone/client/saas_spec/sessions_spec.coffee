describe "Sessions", ->
  beforeEach ->
    withSaas @

  it "should login", ->
    loginPath = rad.router().loginPath({}, false)

    @router.goToLoginPath()
    client.text().should contain: 'Login'

    @server.cachedResponses[loginPath] = {errors: {base: ['some errors']}}
    @router.goToLoginPath()
    client.text().should contain: 'Login'
    client.text().should contain: 'some errors'

    @server.cachedResponses[loginPath] = {}
    @router.spyOn 'back'
    @router.goToLoginPath()
    @router.back.should().haveBeenCalled()

  it "should logout", ->
    @server.cachedResponses[rad.router().logoutPath({}, false)] = {}
    @router.spyOn 'back'
    @router.goToLogoutPath()
    @router.back.should().haveBeenCalled()