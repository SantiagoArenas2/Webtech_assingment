class VisitPolicy < ApplicationPolicy
  def create?
    record.new_record? && host_or_applicant? && record.application.shortlisted?
  end

  def update?
    host_or_applicant? && !record.completed? && !record.cancelled?
  end

  class Scope < Scope
    def resolve
      return scope.none unless user && !user.moderator?

      scope.joins(application: { room: :property })
           .where("applications.seeker_id = :user_id OR properties.host_id = :user_id", user_id: user.id)
    end
  end

  private

  def host_or_applicant?
    user.present? && !user.moderator? &&
      (record.application.seeker_id == user.id || record.application.room.property.host_id == user.id)
  end
end
