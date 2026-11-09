class ReportPolicy < ApplicationPolicy
  def index?
    user&.moderator? || false
  end

  def create?
    user.present?
  end

  def resolve?
    user&.moderator? && record.pending?
  end

  class Scope < Scope
    def resolve
      return scope.all if user&.moderator?
      return scope.none unless user

      scope.where(reporter_id: user.id)
    end
  end
end
