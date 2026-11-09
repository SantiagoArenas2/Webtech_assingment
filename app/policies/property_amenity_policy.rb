class PropertyAmenityPolicy < ApplicationPolicy
  def create?
    user.present? && (user.moderator? || record.property.host_id == user.id)
  end

  def destroy?
    create?
  end
end
