module Pagination
  def paginator_for page, entries_count, per_page, &to_link
    page.must.be >= 1
    return if page == 1 and entries_count < per_page

    opt = {
      current_page: page,
      pages: [], #(go_prev + [current] + go_next),
      to_link: to_link
    }

    opt[:prev] = to_link.call(t(:go_prev), page - 1) if page > 1
    opt[:next] = to_link.call(t(:go_next), page + 1)

    b.paginator opt
  end
end