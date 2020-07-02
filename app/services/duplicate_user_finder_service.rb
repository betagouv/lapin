class DuplicateUserFinderService
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def perform
    user_with_same_email = users_in_scope.where.not(email: nil).find_by(email: @user.email)
    return user_with_same_email if user_with_same_email.present?

    similar_users = User.none
    if @user.phone_number.present?
      similar_users = similar_users.or(users_in_scope.where(phone_number: @user.phone_number))
    end
    if @user.birth_date.present? && @user.first_name.present? && @user.last_name.present?
      similar_users = similar_users.or(
        users_in_scope.where(
          first_name: @user.first_name.capitalize,
          last_name: @user.last_name.upcase,
          birth_date: @user.birth_date
        )
      )
    end
    similar_users.left_joins(:rdvs).group(:id).order('COUNT(rdvs.id) DESC').first
  end

  private

  def users_in_scope
    User.active
  end
end
