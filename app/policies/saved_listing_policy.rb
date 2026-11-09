class SavedListingPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def create?
    user.present? && record.seeker_id == user.id
  end

  def destroy?
    user.present? && record.seeker_id == user.id
  end

  class Scope < Scope
    def resolve
      user ? scope.where(seeker_id: user.id) : scope.none
    end
  end
end
