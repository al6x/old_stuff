# Views

class Views.SpaceRow extends Rad.View
  tagName: 'tr'

  initialize: =>
    @model.bind @render

  render: =>
    @el.updateWith $.build('/spaces/row', model: @model, view: @)
    @delegateEvents()
    @

class Views.SpaceList extends Rad.View
  events:
    'click ._create' : '_create'

  initialize: =>
    @collection.bind @render

  render: =>
    @el.updateWith $.build('/spaces/list', collection: @collection)
    content = @el.find('._content')
    @collection.each (model) ->
      item = Views.SpaceRow.new(model: model)
      content.append item.render().el

    @delegateEvents()
    @

  _create: =>
    rad.dialog().show Models.Space.new(), '/spaces/form', (model, dialog) ->
      model.save ->
        if model.valid()
          dialog.close()
          rad.router().goToSpacePath model
          rad.application().info t('space_created')


class Views.Space extends Rad.View
  events:
    'click ._edit'   : '_edit'
    'click ._delete' : '_delete'

  initialize: =>
    @model.bind @render

  render: =>
    @el.updateWith $.build('/spaces/show', model: @model, view: @)
    @delegateEvents()
    @

  _edit: =>
    rad.dialog().show @model, '/spaces/form', (model, dialog) ->
      model.save ->
        if model.valid()
          dialog.close()
          rad.application().info t('space_updated')

  _delete: =>
    if confirm t('are_you_shure')
      @model.delete =>
        rad.router().goToSpacesPath()
        rad.application().info t('space_deleted', space: @model.name)

# Controller

class Controllers.Spaces
  all: =>
    Models.Space.all page: rad.params().page, (spaces) ->
      view = Views.SpaceList.new(collection: spaces)
      rad.application().set content: view

  read: =>
    Models.Space.read rad.params().id, (space) ->
      view = Views.Space.new(model: space)
      rad.application().set content: view

rad.register 'spaces', ->
  Controllers.Spaces.new()