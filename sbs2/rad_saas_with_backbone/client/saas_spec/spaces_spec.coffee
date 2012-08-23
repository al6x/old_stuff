describe "Spaces", ->
  beforeEach ->
    withSaas @
    rad.setUser factory.create('global_admin')
    @space = factory.create('space')

  it "should show spaces", ->
    @server.stub '/spaces', [@space]

    @router.goToSpacesPath()
    client.text().should contain: 'Spaces'
    client.text().should contain: @space.name

  it "should show space", ->
    @server.stub "/spaces/#{@space.name}", @space

    @router.goToSpacePath @space
    client.text().should contain: @space.name

  it "should create space", ->
    @server.stub '/spaces', [@account]

    @router.goToSpacesPath()
    client.click('Create')
    client.text().should contain: 'New Space'

  it "should update space", ->
    @server.stub "/spaces/#{@space.name}", @space
    @router.goToSpacePath @space

    client.click 'Edit'
    client.text().should contain: "Edit #{@space.name}"

  it "should delete space", ->
    @server.stub "/spaces/#{@space.name}", @space

    @router.goToSpacePath @space
    client.text().should contain: 'Delete'