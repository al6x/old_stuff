describe "Model & Collection", ->
  beforeEach ->
    class Spec.User extends Rad.RemoteModel
      @resource: '/users'

  describe "CRUD", ->
    it "should read", ->
      rad.server().stub '/users/alex', {name: 'alex'}
      model = null
      Spec.User.read 'alex', (r) -> model = r
      model.name.should be: 'alex'

    it "should return null if response is null", ->
      rad.server().stub '/users/alex', null
      (->
        Spec.User.read 'alex', (r) ->
      ).should raise: 'model not exist (/users/alex)!'

    it "should return all", ->
      rad.server().stub '/users/all', [{name: 'alex'}, {name: 'john'}]
      users = null
      Spec.User.all (r) -> users = r
      users.size().should be: 2

      user = users.first()
      user.name.should be: 'alex'
      user.constructor.should be: Spec.User

  it "should emit events", ->
    user = Spec.User.new()
    events = []
    user.bind 'change', -> events.add 'change'
    user.bind 'all', -> events.add 'all'
    user.trigger 'change'
    events.should be: ['change', 'all']

  it "shoud delete models from collection", ->
    alex = Spec.User.new(name: 'alex')
    john = Spec.User.new(name: 'john')
    col = Rad.Collection.new([alex, john])
    col.delete alex
    col.size().should be: 1
    col.first().should be: john