class AmenitiesController < ApplicationController
  def index
    authorize Amenity, :index?
    @amenities = Amenity.order(:name)
  end

  def new
    @amenity = Amenity.new
    authorize @amenity, :create?
  end

  def create
    @amenity = Amenity.new(amenity_params)
    authorize @amenity, :create?
    if @amenity.save
      redirect_to amenities_path, notice: "Amenity created."
    else
      flash.now[:alert] = "Please correct the amenity form."
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @amenity = Amenity.find(params[:id])
    authorize @amenity, :update?
  end

  def update
    @amenity = Amenity.find(params[:id])
    authorize @amenity, :update?
    if @amenity.update(amenity_params)
      redirect_to amenities_path, notice: "Amenity updated."
    else
      flash.now[:alert] = "Please correct the amenity form."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    amenity = Amenity.find(params[:id])
    authorize amenity, :destroy?
    amenity.destroy!
    redirect_to amenities_path, notice: "Amenity deleted."
  rescue ActiveRecord::DeleteRestrictionError, ActiveRecord::RecordNotDestroyed
    redirect_to amenities_path, alert: "Could not delete this amenity."
  end

  private

  def amenity_params
    params.require(:amenity).permit(:name)
  end
end
