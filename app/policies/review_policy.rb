class ReviewPolicy < ApplicationPolicy
  def create?
    user.present? && !user.moderator? &&
      record.visit&.completed? && record.visit.application.seeker_id == user.id
  end

  def update?
    user.present? && !user.moderator? && record.author_id == user.id
  end

  def destroy?
    user.present? && (user.moderator? || record.author_id == user.id)
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
