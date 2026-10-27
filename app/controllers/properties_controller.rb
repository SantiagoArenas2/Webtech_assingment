class PropertiesController < ApplicationController
  def index
    @properties = Property.includes(:neighborhood, :rooms)
  end

  def show
    @property = Property.includes(:neighborhood, :amenities, rooms: :room_photos, reviews: :author)
                         .find(params[:id])
    @rooms = @property.rooms.published
    @rooms = @rooms.or(@property.rooms.where(status: :draft)) if @property.host_id == current_user&.id
    @review = @property.reviews.new
    @completed_visits = Visit.joins(application: :room)
                             .where(status: :completed, applications: { seeker_id: current_user&.id },
                                    rooms: { property_id: @property.id })
                             .where.not(id: Review.where.not(visit_id: nil).select(:visit_id))
  end

  def new
    @property = Property.new
  end

  def create
    @property = Property.new(property_params)
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
    raise ActiveRecord::RecordNotFound unless property.host_id == current_user&.id

    property
  end

  def property_params
    params.require(:property).permit(:address, :neighborhood_id, :property_type, :bedrooms, :bathrooms,
                                    :shared_spaces, :description, amenity_ids: [])
  end
end
