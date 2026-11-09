class ReviewsController < ApplicationController
  def create
    @property = Property.find(params[:property_id])
    @review = @property.reviews.new(review_params)
    @review.author = current_user
    @review.visit = Visit.find(@review.visit_id) if @review.visit_id.present?
    authorize @review, :create?
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
    @review = @property.reviews.find(params[:id])
    authorize @review, :update?
  end

  def update
    @property = Property.find(params[:property_id])
    @review = @property.reviews.find(params[:id])
    authorize @review, :update?
    if @review.update(review_params.except(:visit_id))
      redirect_to property_path(@property), notice: "Review updated."
    else
      flash.now[:alert] = "Please correct the review form."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    property = Property.find(params[:property_id])
    review = property.reviews.find(params[:id])
    authorize review, :destroy?
    review.destroy!
    redirect_to property_path(property), notice: "Review deleted."
  end

  private

  def review_params
    params.require(:review).permit(:visit_id, :rating, :comment)
  end

  def load_property_context
    @rooms = @property.rooms.published
    @rooms = @rooms.or(@property.rooms.where(status: :draft)) if current_user &&
      (@property.host_id == current_user.id || current_user.moderator?)
    @completed_visits = Visit.joins(application: :room)
                             .where(status: :completed, applications: { seeker_id: current_user&.id },
                                    rooms: { property_id: @property.id })
                             .where.not(id: Review.where.not(visit_id: nil).select(:visit_id))
  end
end
