c.resource :analytics, class_name: 'Controllers::Analytics'


class Analytics < SaasStandaloneApp
  require_permission :administrate

  layout '/saas/layout'

  allow_get_for :all

  def all
    @page = params.page || 1
    @per_page = Models::Item::PER_PAGE
    year, month = Time.now.year, Time.now.month
    @domains = Models::Domain.sort(["views.#{year}.#{month}".to_sym, -1]).paginate(@page, @per_page).all
  end
end