describe "Dialog", ->
  beforeEach ->
    withSaas @

    $.templates['/spec/dialog'] = $.compileTemplate """
    <div>
      <%= model.name %>
      <button class='_ok'>Ok</button>
      <button class='_cancel'>Cancel</button>
    </div>
    """

  it "should display and close dialog", ->
    model = Rad.Model.new(name: 'some name')
    rad.dialog().show
      model     : model
      template  : "/spec/dialog"

    client.text().should contain: 'some name'

    client.click 'Cancel'
    client.text().shouldNot contain: 'some name'

  it "should trigger :ok action", ->
    model = Rad.Model.new(name: 'some name')
    called = false

    rad.dialog().show
      model     : model
      template  : "/spec/dialog"
      ok        : (aModel, dialog) =>
        dialog.close()
        aModel.should be: model
        called = true

    client.text().should contain: 'some name'

    client.click 'Ok'
    client.text().shouldNot contain: 'some name'
    called.should be: true