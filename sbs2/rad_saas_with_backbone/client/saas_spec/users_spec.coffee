describe "Users", ->
  beforeEach ->
    withSaas @
    rad.setUser factory.create('anonymous')
    rad.setParams space_name: 'default'
    @user = factory.create('user')

  it "should show users", ->
    @server.stub '/default/users', [@user]

    @router.goToUsersPath()
    client.text().should contain: 'Users'
    client.text().should contain: @user.name

  it "should show user", ->
    @server.stub "/default/users/#{@user.name}", @user

    @router.goToUserPath @user
    client.text().should contain: @user.name

  it "should update user", ->
    rad.setUser @user

    @server.stub "/default/users/#{@user.name}", @user
    @router.goToUserPath(@user)

    client.click('Edit')
    client.text().should contain: "Edit #{@user.name}"

  it "should add role", ->
    rad.setUser factory.create('admin')

    @server.stub "/default/users/#{@user.name}", @user
    @router.goToUserPath(@user)
    client.text().should match: /Role.*user/

    member = @user.clone()
    member.roles.add 'member'
    member.role = 'member'
    @server.stub "/default/users/#{@user.name}/add_role", member
    client.click('Add to Members')

    client.text().should match: /Role.*member/

  it "should delete role", ->
    rad.setUser factory.create('admin')
    member = factory.create 'member'

    @server.stub "/default/users/#{member.name}", member
    @router.goToUserPath(member)
    client.text().should match: /Role.*member/

    user = member.clone()
    user.roles.delete 'member'
    user.role = 'user'
    @server.stub "/default/users/#{member.name}/delete_role", user
    client.click('Remove from Members')

    client.text().should match: /Role.*user/