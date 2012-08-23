describe "Accounts", ->
  beforeEach ->
    withSaas @
    rad.setUser factory.create('global_admin')
    @account = factory.create('account')

  it "should show accounts", ->
    @server.stub '/accounts', [@account]

    @router.goToAccountsPath()
    client.text().should contain: 'Accounts'
    client.text().should contain: @account.name

  it "should show account", ->
    @server.stub "/accounts/#{@account.name}", @account

    @router.goToAccountPath @account
    client.text().should contain: @account.name

  it "should create account", ->
    @server.stub '/accounts', [@account]

    @router.goToAccountsPath()
    client.click('Create')
    client.text().should contain: 'New Account'

  it "should update account", ->
    @server.stub "/accounts/#{@account.name}", @account
    @router.goToAccountPath @account

    client.click 'Edit'
    client.text().should contain: "Edit #{@account.name}"

  it "should delete account", ->
    @server.stub "/accounts/#{@account.name}", @account

    @router.goToAccountPath @account
    client.text().should contain: 'Delete'