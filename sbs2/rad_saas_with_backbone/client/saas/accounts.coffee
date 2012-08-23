# Views

spaceLinks = ->
  @model.spaces.map (space) =>
    $.buildAsString 'a', space.name, href: rad.router().spaceFullPath(@model, space)

class Views.AccountRow extends Rad.View
  tagName: 'tr'

  initialize: =>
    @model.bind @render

  render: =>
    @el.updateWith $.build('/accounts/row', model: @model, view: @)
    @delegateEvents()
    @

  spaceLinks: spaceLinks

class Views.AccountList extends Rad.View
  events:
    'click ._create' : '_create'

  initialize: =>
    @collection.bind @render

  render: =>
    @el.updateWith $.build('/accounts/list', collection: @collection)
    content = @el.find('._content')
    @collection.each (model) ->
      item = Views.AccountRow.new(model: model)
      content.append item.render().el

    paginator = Models.Paginator.new(collection: @collection, page: rad.params().page)
    @el.find('._paginator').replaceWith paginator.view().render().el

    @delegateEvents()
    @

  _create: =>
    rad.dialog().show Models.Account.new(), '/accounts/form', (model, dialog) ->
      model.save ->
        if model.valid()
          dialog.close()
          rad.router().goToAccountPath model
          rad.application().info t('account_created')


class Views.Account extends Rad.View
  events:
    'click ._edit'   : '_edit'
    'click ._delete' : '_delete'

  initialize: =>
    @model.bind @render

  render: =>
    @el.updateWith $.build('/accounts/show', model: @model, view: @)
    @delegateEvents()
    @

  _edit: =>
    rad.dialog().show @model, '/accounts/form', (model, dialog) ->
      model.save ->
        if model.valid()
          dialog.close()
          rad.application().info t('account_updated')

  _delete: =>
    if confirm t('are_you_shure')
      @model.delete =>
        rad.router().goToAccountsPath()
        rad.application().info t('account_deleted', account: @model.name)

  spaceLinks: spaceLinks

# Controller

class Controllers.Accounts
  all: =>
    Models.Account.all page: rad.params().page, (accounts) ->
      view = Views.AccountList.new(collection: accounts)
      rad.application().set content: view

  read: =>
    Models.Account.read rad.params().id, (account) ->
      view = Views.Account.new(model: account)
      rad.application().set content: view

rad.register 'accounts', ->
  Controllers.Accounts.new()