class CaseScope
  # -- lifetime --
  def initialize(path, user)
    @path_scope = extract_scope_from_path(path)
    @user_scope = whitelist_scope(user.role)
  end

  # -- queries --
  def permit?
    @path_scope.present? && @path_scope == @user_scope
  end

  def reject?
    not permit?
  end

  # rewrites the path using the user's scope. replaces the existing
  # scope, if necessary.
  def rewrite_path(path)
    uri = URI(path)

    # remove existing scope
    if not @path_scope.nil?
      uri.path = uri.path.gsub(/#{@path_scope}\/?/, "")
    end

    # don't rescope if root
    if @user_scope == :root
      return uri.to_s
    end

    # otherwise, add user's scope
    parts = uri.path.split("/")
    parts.insert(2, @user_scope.to_s)
    uri.path = parts.join("/")

    uri.to_s
  end

  # -- helpers --
  private def extract_scope_from_path(path)
    if path.nil?
      return nil
    end

    uri = URI(path)

    parts = uri.path.split("/")
    if parts[1] != "cases"
      return nil
    end

    whitelist_scope(parts[2], :root)
  end

  private def whitelist_scope(value, default = nil)
    scope = value&.to_sym
    case scope
    when :supplier, :dhs, :enroller
      scope
    when :cohere
      :root
    else
      default
    end
  end
end
