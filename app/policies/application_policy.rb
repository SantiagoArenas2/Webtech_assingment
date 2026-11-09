class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    user.present?
  end

  def show?
    user.present? && (user.moderator? || record.seeker_id == user.id || record.room.property.host_id == user.id)
  end

  def create?
    user.present? && record.room.published? && record.room.property.host_id != user.id
  end

  def new?
    create?
  end

  def update?
    user.present? && !user.moderator? && record.room.property.host_id == user.id
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  def withdraw?
    user.present? && record.seeker_id == user.id && (record.pending? || record.shortlisted?)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      return scope.all if user&.moderator?
      return scope.none unless user

      scope.left_joins(room: :property).where(seeker_id: user.id)
           .or(scope.left_joins(room: :property).where(properties: { host_id: user.id }))
    end
  end
end
