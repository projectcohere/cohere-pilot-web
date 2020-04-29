module Cases
  module BaseHelper
    include Case::Policy::Context::Shared

    # -- search --
    def cases_search_params
      return request.query_parameters
    end

    def cases_search_path(params = nil)
      if params == nil
        return request.path
      end

      uri = URI.parse(request.fullpath)
      uri.query = cases_search_params.merge(params).to_query

      return uri.to_s
    end

    # -- filters --
    def cases_scope_link_to(scope)
      return link_to(scope.name, cases_search_path(scope: scope.key),
        id: "filter-#{scope.key}",
        class: cx(
          "Filter",
          "is-selected": @scope == scope,
        ),
      )
    end

    # -- cells --
    def case_cell_options(view, shows_status: true, shows_activity: false)
      return {
        id: "case-#{view.id}",
        class: cx(
          "CaseCell",
          "CaseCell-#{view.status}" => shows_status == true || shows_status == view.status,
          "is-active" => shows_activity && view.new_activity?,
        )
      }
    end
  end
end
