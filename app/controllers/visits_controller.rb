class VisitsController < ApplicationController
  before_action :set_application

  def create
    @visit = @application.build_visit(visit_params)
    authorize @visit, :create?
    if @visit.save
      redirect_to application_path(@application), notice: "Visit proposed."
    else
      flash.now[:alert] = "Please correct the visit form."
      render "applications/show", status: :unprocessable_entity
    end
  end

  def update
    @visit = @application.visit
    raise ActiveRecord::RecordNotFound unless @visit
    authorize @visit, :update?

    requested_status = params.dig(:visit, :status)
    if requested_status == "cancelled"
      @visit.status = :cancelled
    elsif requested_status.in?(%w[confirmed completed]) &&
          @application.room.property.host_id == current_user.id
      @visit.status = requested_status
    elsif requested_status.present?
      raise Pundit::NotAuthorizedError
    else
      raise Pundit::NotAuthorizedError unless @application.room.property.host_id == current_user.id

      @visit.scheduled_at = visit_params[:scheduled_at]
      @visit.status = :rescheduled
    end
    if @visit.save
      redirect_to application_path(@application), notice: "Visit updated."
    else
      flash.now[:alert] = "Please correct the visit form."
      render "applications/show", status: :unprocessable_entity
    end
  end

  private

  def set_application
    @application = policy_scope(Application).find_by(id: params[:application_id])
    raise Pundit::NotAuthorizedError unless @application
  end

  def visit_params
    params.require(:visit).permit(:scheduled_at)
  end
end
