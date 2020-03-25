module Cases
  module BaseHelper
    def cases_is_open
      @scope == Cases::Scope::Open
    end

    def cases_filter_link_to(scope)
      return link_to(scope.name, "#{cases_path}/#{scope.path}",
        id: "filter-#{scope.path}",
        class: cx(
          "Filter",
          "is-selected": @scope == scope,
        ),
      )
    end

    def case_cell_options(view, shows_activity: false)
      return {
        id: "case-#{view.id}",
        class: cx(
          "CaseCell",
          "is-active" => shows_activity && view.has_new_activity
        )
      }
    end
  end
end
