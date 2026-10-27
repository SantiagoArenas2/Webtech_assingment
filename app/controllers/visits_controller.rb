class VisitsController < ApplicationController
  before_action :set_application

  def create
    @visit = @application.build_visit(visit_params)
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

    if %w[confirmed completed cancelled].include?(params.dig(:visit, :status))
      @visit.status = params[:visit][:status]
    else
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
    @application = Application.joins(room: :property)
                              .where(properties: { host_id: current_user&.id })
                              .find(params[:application_id])
  end

  def visit_params
    params.require(:visit).permit(:scheduled_at)
  end
end
