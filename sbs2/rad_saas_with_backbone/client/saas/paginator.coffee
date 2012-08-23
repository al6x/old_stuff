class Models.Paginator extends Rad.Model
  constructor: (args...) ->
    super args...
    @page = parseInt @page || 1
    @perPage = parseInt @perPage || rad.config().perPage || 25

  view: ->
    @_view ||= Views.Paginator.new(model: @)

class Views.Paginator extends Rad.View
  initialize: =>
    @model.bind @render

  render: =>
    @el.updateWith $.build('/paginator', model: @model, view: @)
    @delegateEvents()
    @

  nextLink: =>
    unless @model.collection.size() < @model.perPage
      nextPage = @model.page + 1
      rad.router().buildUrl rad.path(), rad.params().extend(page: nextPage)

  prevLink: =>
    if (prevPage = @model.page - 1) >= 1
      rad.router().buildUrl rad.path(), rad.params().extend(page: prevPage)