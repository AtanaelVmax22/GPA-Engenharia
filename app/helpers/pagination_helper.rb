module PaginationHelper
  def pagination_metadata(collection, page:, per_page:)
    total_count = collection.count
    total_pages = (total_count.to_f / per_page).ceil
    current_page = page.to_i < 1 ? 1 : page.to_i
    offset = (current_page - 1) * per_page

    {
      records: collection.offset(offset).limit(per_page),
      current_page: current_page,
      total_pages: total_pages,
      total_count: total_count,
      per_page: per_page,
      offset: offset
    }
  end

  def pagination_link_params(page)
    request.query_parameters.merge(page: page)
  end
end