describe "Localization", ->
  beforeEach ->
    withSaas @

  it "should provide localized messages", ->
    rad.router().goToRegisterPath()
    client.text().should contain :'Signup'

    rad.router().goToRegisterPath(l: 'ru')
    client.text().should contain: 'Регистрация'

describe "Notifications", ->
  afterEach ->
    rad.notifications().clear()

  it "should show notification", ->
    rad.router().navigate '/test'
    rad.application().info 'Important message!', sticky: true
    client.text().should contain: 'Important message!'