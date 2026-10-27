class ReviewsController < ApplicationController
  def create
    @property = Property.find(params[:property_id])
    @review = @property.reviews.new(review_params)
    @review.author = current_user
    if @review.save
      redirect_to property_path(@property), notice: "Review submitted."
    else
      flash.now[:alert] = "Please correct the review form."
      load_property_context
      render "properties/show", status: :unprocessable_entity
    end
  end

  def edit
    @property = Property.find(params[:property_id])
    @review = @property.reviews.find_by!(id: params[:id], author_id: current_user&.id)
  end

  def update
    @property = Property.find(params[:property_id])
    @review = @property.reviews.find_by!(id: params[:id], author_id: current_user&.id)
    if @review.update(review_params.except(:visit_id))
      redirect_to property_path(@property), notice: "Review updated."
    else
      flash.now[:alert] = "Please correct the review form."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    property = Property.find(params[:property_id])
    property.reviews.find_by!(id: params[:id], author_id: current_user&.id).destroy!
    redirect_to property_path(property), notice: "Review deleted."
  end

  private

  def review_params
    params.require(:review).permit(:visit_id, :rating, :comment)
  end

  def load_property_context
    @rooms = @property.rooms.published
    @rooms = @rooms.or(@property.rooms.where(status: :draft)) if @property.host_id == current_user&.id
    @completed_visits = Visit.joins(application: :room)
                             .where(status: :completed, applications: { seeker_id: current_user&.id },
                                    rooms: { property_id: @property.id })
                             .where.not(id: Review.where.not(visit_id: nil).select(:visit_id))
  end
end
