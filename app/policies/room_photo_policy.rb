class RoomPhotoPolicy < ApplicationPolicy
  def show?
    RoomPolicy.new(user, record.room).show?
  end

  def create?
    user.present? && (user.moderator? || record.room.property.host_id == user.id)
  end

  def destroy?
    create?
  end

  class Scope < Scope
    def resolve
      visible_room_ids = RoomPolicy::Scope.new(user, Room).resolve.select(:id)
      scope.where(room_id: visible_room_ids)
    end
  end
end
