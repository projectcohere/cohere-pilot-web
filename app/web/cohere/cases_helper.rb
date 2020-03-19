module Cohere
  module CasesHelper
    # -- impls --
    def cases_is_open
      @scope == CaseScope::Open
    end

    def cases_filter_link_to(scope)
      return link_to(scope.name, "#{cases_path}/#{scope.path}", class: cx(
        "Filter",
        "is-selected": @scope == scope,
      ))
    end

    def cases_list_options
      options = {
        class: "CaseList"
      }

      if cases_is_open
        options[:id] = "case-list"
      end

      return options
    end

    def cases_cell_options(view)
      options = {}

      if cases_is_open
        options[:id] = "case-#{view.id}"
      end

      options[:class] = cx(
        "CaseCell",
        "is-active" => view.has_new_activity && cases_is_open,
      )

      return options
    end
  end
end
