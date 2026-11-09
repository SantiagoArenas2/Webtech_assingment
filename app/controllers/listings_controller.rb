class ListingsController < ApplicationController
  allow_unauthenticated_access only: %i[index show]

  def index
    authorize Room, :index?
    @rooms = policy_scope(Room).published.includes(:room_photos, property: :neighborhood)
    @neighborhoods = Neighborhood.order(:name)

    if params[:neighborhood_id].present?
      @rooms = @rooms.joins(:property).where(properties: { neighborhood_id: params[:neighborhood_id] })
    end
    @rooms = @rooms.under_rent(params[:max_rent]) if params[:max_rent].present?
    @rooms = @rooms.available_from_date(params[:available_from]) if params[:available_from].present?
  end

  def show
    @room = Room.includes(:room_photos, :photographs_attachments,
                          property: [ :neighborhood, :amenities, :reviews ]).find(params[:id])
    authorize @room

    @application = @room.applications.find_by(seeker: current_user)
    @new_application = @room.applications.new
  end

  def new
    @property = Property.find(params[:property_id])
    authorize @property, :update?
    @room = @property.rooms.new
    authorize @room, :create?
  end

  def create
    @property = Property.find(params[:property_id])
    authorize @property, :update?
    @room = @property.rooms.new(room_params)
    authorize @room, :create?
    if @room.save
      redirect_to listing_path(@room), notice: "Draft listing created."
    else
      flash.now[:alert] = "Please correct the listing form."
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @room = owned_listing
  end

  def update
    @room = owned_listing
    if @room.update(room_params)
      redirect_to listing_path(@room), notice: "Listing updated."
    else
      flash.now[:alert] = "Please correct the listing form."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    room = owned_listing
    room.destroy!
    redirect_to properties_path, notice: "Listing deleted."
  end

  def publish
    transition_listing(:publish?) { owned_listing.publish! }
  end

  def withdraw
    transition_listing(:withdraw?) { owned_listing.withdraw! }
  end

  def mark_rented
    transition_listing(:mark_rented?) { owned_listing.mark_rented! }
  end

  private

  def owned_listing
    room = Room.find(params[:id])
    authorize room, :update?
    room
  end

  def room_params
    params.require(:room).permit(:label, :price, :deposit, :available_from, :minimum_stay_months,
                                 :furnished, :private_bathroom, :description, :house_rules,
                                 photographs: [])
  end

  def transition_listing(action)
    room = Room.find(params[:id])
    authorize room, action
    yield
    redirect_to listing_path(params[:id]), notice: "Listing status updated."
  rescue ActiveRecord::RecordInvalid => error
    redirect_to listing_path(params[:id]), alert: error.record.errors.full_messages.to_sentence
  end
end
