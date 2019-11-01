class CaseScope
  # the underlying policy for this scope
  attr(:policy)

  # -- lifetime --
  def initialize(scope, user)
    @policy ||= Case::Policy.new(
      user,
      scope: scope
    )
  end

  # -- queries --
  def scoped?
    @policy.permit?(:some)
  end

  def scoped_path(path)
    scope = @policy.scope_for_user
    if scope == :root
      return path
    end

    parts = path.split("/")
    parts.insert(2, scope.to_s)
    parts.join("/")
  end

  def scoped_url(url)
    ENV["HOST"] + scoped_path(url.delete_prefix(ENV["HOST"]))
  end
end
