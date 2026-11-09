class SessionPolicy < ApplicationPolicy
  def show?
    user.present? && record.user_id == user.id
  end

  def destroy?
    show?
  end

  class Scope < Scope
    def resolve
      user ? scope.where(user_id: user.id) : scope.none
    end
  end
end
