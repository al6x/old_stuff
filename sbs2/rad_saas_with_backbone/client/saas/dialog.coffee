class Models.Dialog extends Rad.Model
  view: ->
    @_view ||= Views.Dialog.new(model: @)

  show: (args...) ->
    if args.size() == 1
      options = args.first()
    else
      options = {}
      [options.model, options.template, options.ok] = args

    # We need also propagate events of the underlying model to view.
    formModel = options['model'] || raise('no form model!')
    formModel.bind => @trigger('change')

    # Saving current state of application and displaying dialog.
    app = rad.application()
    previousAppState = {layout: app.layout, content: app.content}
    @set options.extend(previousAppState: previousAppState)
    app.set layout: 'narrow', content: @.view()

  close: ->
    rad.application().set @previousAppState

  # validate: (attrs) ->
  #   ['model', 'template', 'previousAppState'].each (attr) =>
  #     throw "no #{attr} attribute!" unless attrs.hasProperty attr
  #   null

class Views.Dialog extends Rad.View
  events:
    'click ._ok'     : '_ok'
    'click ._cancel' : '_close'
    'click ._back'   : '_back'

  initialize: =>
    @model.bind @render

  render: =>
    @el.updateWith $.build('/dialog', model: @model)
    content = $.render(@model.template, model: @model.model)
    @el.find('._content').replaceWith content
    @delegateEvents()
    @

  _ok: =>
    # Updating model from form.
    formModel = @model.model
    formAttributes = @el.find('form').serializeHash()
    formModel.set formAttributes, silent: true

    # Passing control to external controller, so it can save model
    # and close dialog if needed.
    @model.ok?(formModel, @model)
    false

  _close: =>
    @model.close()
    false

  _back: =>
    @model.close()
    rad.router().back()
    false

rad.register 'dialog', 'instance', ->
  Models.Dialog.new()