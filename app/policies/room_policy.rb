class RoomPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    return false unless user || record.published?

    record.published? || user&.moderator? || record.property.host_id == user&.id
  end

  def create?
    user.present?
  end

  def update?
    user.present? && (user.moderator? || record.property.host_id == user.id)
  end

  def destroy?
    update?
  end

  def publish?
    update?
  end

  def withdraw?
    update?
  end

  def mark_rented?
    update?
  end

  class Scope < Scope
    def resolve
      published = scope.published
      return scope.all if user&.moderator?
      return published unless user

      scope.left_joins(:property).where(status: "published")
           .or(scope.left_joins(:property).where(properties: { host_id: user.id }))
    end
  end
end
