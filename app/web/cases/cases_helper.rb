module Cases
  module CasesHelper
    def cases_is_open
      @scope == Cases::Scope::Open
    end

    def cases_filter_link_to(scope)
      return link_to(scope.name, "#{cases_path}/#{scope.path}", class: cx(
        "Filter",
        "is-selected": @scope == scope,
      ))
    end

    def cases_cell_options(view)
      return {
        id: "case-#{view.id}",
        class: cx(
          "CaseCell",
          "is-active" => view.has_new_activity
        )
      }
    end
  end
end
