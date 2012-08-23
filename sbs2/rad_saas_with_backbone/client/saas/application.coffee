class Models.Application extends Rad.Model
  defaults:
    layout: 'standard'
    content: null

  view: ->
    @_view ||= Views.Application.new(model: @)

  clear: ->
    @set layout: 'standard', content: null

class Views.Application extends Rad.View
  initialize: =>
    @el = $ '#application'
    @model.bind @render

  render: =>
    @el.empty()
    @el.html $.render("/application/layouts/#{@model.layout}", model: @model)
    @el.find('._notifications').replaceWith rad.notifications().view().render().el
    @el.find('._menu').replaceWith rad.menu().view().render().el
    if content = @model.content
      @el.find('._content').replaceWith content.render().el
    @

# Initialization.
rad.register 'application', 'page', -> Models.Application.new()
rad.router().bind 'route:before', ->
  rad.application().clear()
  rad.application().view().render()