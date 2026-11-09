class PropertiesController < ApplicationController
  allow_unauthenticated_access only: %i[index show]

  def index
    authorize Property, :index?
    @properties = policy_scope(Property).includes(:neighborhood, :rooms)
  end

  def show
    @property = Property.includes(:neighborhood, :amenities, rooms: :room_photos, reviews: :author)
                         .find(params[:id])
    authorize @property
    @rooms = @property.rooms.published
    @rooms = @rooms.or(@property.rooms.where(status: :draft)) if current_user &&
      (@property.host_id == current_user.id || current_user.moderator?)
    @review = @property.reviews.new
    @completed_visits = Visit.joins(application: :room)
                             .where(status: :completed, applications: { seeker_id: current_user&.id },
                                    rooms: { property_id: @property.id })
                             .where.not(id: Review.where.not(visit_id: nil).select(:visit_id))
    @completed_visits = Visit.none unless current_user&.member?
  end

  def new
    @property = Property.new
    authorize @property, :create?
  end

  def create
    @property = Property.new(property_params)
    authorize @property, :create?
    @property.host = current_user
    if @property.save
      redirect_to property_path(@property), notice: "Property created."
    else
      flash.now[:alert] = "Please correct the property form."
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @property = owned_property
  end

  def update
    @property = owned_property
    if @property.update(property_params)
      redirect_to property_path(@property), notice: "Property updated."
    else
      flash.now[:alert] = "Please correct the property form."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    property = owned_property
    property.destroy!
    redirect_to properties_path, notice: "Property deleted."
  rescue ActiveRecord::DeleteRestrictionError
    redirect_to property_path(property), alert: "Delete its listings before deleting this property."
  end

  private

  def owned_property
    property = Property.find(params[:id])
    authorize property, :update?
    property
  end

  def property_params
    params.require(:property).permit(:address, :neighborhood_id, :property_type, :bedrooms, :bathrooms,
                                    :shared_spaces, :description, amenity_ids: [])
  end
end
