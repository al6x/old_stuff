# Views

class Views.UserRow extends Rad.View
  tagName: 'tr'

  initialize: =>
    @model.bind @render

  render: =>
    @el.updateWith $.build('/users/row', model: @model)
    @delegateEvents()
    @

class Views.UserList extends Rad.View
  initialize: =>
    @collection.bind @render

  render: =>
    @el.updateWith $.build('/users/list', collection: @collection)
    content = @el.find('._content')
    @collection.each (model) ->
      item = Views.UserRow.new(model: model)
      content.append item.render().el

    paginator = Models.Paginator.new(collection: @collection, page: rad.params().page)
    @el.find('._paginator').replaceWith paginator.view().render().el

    @delegateEvents()
    @

class Views.User extends Rad.View
  events:
    'click ._edit'          : '_edit'
    'click ._downgradeRole' : '_downgradeRole'
    'click ._upgradeRole'   : '_upgradeRole'

  initialize: =>
    @model.bind @render

  render: =>
    @el.updateWith $.build('/users/show', model: @model, view: @)
    @delegateEvents()
    @

  showOwnerControls: =>
    (rad.user().name == @model.name) and (@model.name != 'anonymous')

  showUpgradeButton: =>
    (@model.role != 'admin') and rad.user().can("manage_#{@_upperRole()}s") and
    (@model.name != 'anonymous')

  showDowngradeButton: =>
    (@model.role != 'user') and rad.user().can("manage_#{@model.role}s") and
    (@model.name != 'anonymous')

  upgradeButtonMessage: => t("add_to_#{@_upperRole()}s")

  downgradeButtonMessage: => t("delete_from_#{@model.role}s")

  _upgradeRole: =>
    @model.addRole @_upperRole(), ->
      rad.application().info t('user_updated')

  _downgradeRole: =>
    @model.deleteRole @model.role, ->
      rad.application().info t('user_updated')

  _edit: =>
    rad.dialog().show @model, '/users/form', (model, dialog) ->
      model.save ->
        if model.valid()
          dialog.close()
          rad.application().info t('user_updated')

  _upperRole: =>
    orderedRoles = ['user', 'member', 'manager', 'admin']
    current = orderedRoles.indexOf @model.role
    orderedRoles[current + 1]

# Controller

class Controllers.Users
  all: =>
    Models.User.all page: rad.params().page, (users) ->
      view = Views.UserList.new(collection: users)
      rad.application().set content: view

  read: =>
    Models.User.read rad.params().id, (user) ->
      view = Views.User.new(model: user)
      rad.application().set content: view

rad.register 'users', ->
  Controllers.Users.new()