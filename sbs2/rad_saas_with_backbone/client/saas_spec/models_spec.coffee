describe "User Model", ->
  beforeEach ->
    withSaas @
    rad.setParams space_name: 'default'

  it "should return all users", ->
    data = [{name: 'alex'}, {name: 'john'}]
    @server.stub '/default/users', data
    users = null
    Models.User.all (list) -> users = list
    users.map((u) -> u.name).should be: ['alex', 'john']