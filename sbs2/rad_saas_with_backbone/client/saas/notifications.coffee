class Models.Notification extends Rad.Model
  defaults:
    type: 'info'

  view: ->
    @_view ||= Views.Notification.new(model: @)

class Views.Notification extends Rad.View
  events:
    'click ._close': 'close'

  initialize: =>
    @model.bind @render

  render: =>
    @el.updateWith $.build('/notification', model: @model)
    @delegateEvents()
    @

  close: =>
    rad.notifications().delete @model
    rad.notifications().trigger()
    false

class Models.Notifications extends Rad.Collection
  view: ->
    @_view ||= Views.Notifications.new(collection: @)

class Views.Notifications extends Rad.View
  initialize: =>
    @collection.bind @render
    @render()

  render: =>
    @el.updateWith $.build('/notifications', model: @model)
    @collection.each (notification) =>
      @el.append notification.view().render().el
    @

# Initialization.
rad.register 'notifications', 'page', ->
  Models.Notifications.new()

# Shortcuts.
Models.Application.prototype.extend
  showNotification: (message, options = {}) ->
    notification = Models.Notification.new(options.extend(message: message))
    if options.sticky
      ns = rad.notifications()
      ns.add notification
      ns.trigger()
    else
      $.jGrowl notification.message, position: 'bottom-right'
    notification
  info: (message, options = {}) -> @showNotification message, options.extend(type: 'info')
  warn: (message, options = {}) -> @showNotification message, options.extend(type: 'warn')
  error: (message, options = {}) -> @showNotification message, options.extend(type: 'error')