module Authorization
  def user_repo
    return @user_repo || User::Repo.get
  end

  def user
    return user_repo.find_current
  end

  def user_role
    return user&.role
  end

  def user_membership
    return user_role&.membership
  end

  def user_partner_id
    return user&.role&.partner_id
  end
end
