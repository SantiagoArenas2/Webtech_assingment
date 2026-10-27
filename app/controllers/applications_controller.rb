class ApplicationsController < ApplicationController
  def index
    @applications = Application.joins(room: :property).where(properties: { host_id: current_user&.id })
                               .includes(:seeker, room: :property).order(created_at: :desc)
    @pending_count = @applications.pending_answer.count
  end

  def show
    @application = host_application
    @visit = @application.visit
  end

  def create
    @room = Room.find(params[:listing_id])
    @new_application = @room.applications.new(application_params)
    @new_application.seeker = current_user
    if @new_application.save
      @application = @new_application
      flash.now[:notice] = "Application submitted."
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to listing_path(@room), notice: "Application submitted." }
      end
    else
      @application = nil
      flash.now[:alert] = "Please correct the application form."
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("application_block", partial: "listings/application_block",
                                 locals: { room: @room, application: nil, new_application: @new_application }),
            turbo_stream.replace("flash_messages", partial: "layouts/flash_messages", locals: { messages: flash })
          ], status: :unprocessable_entity
        end
        format.html { render "listings/show", status: :unprocessable_entity }
      end
    end
  end

  def update
    @application = host_application
    action = params.dig(:application, :status)
    if action == "accepted"
      @application.accept!
    elsif %w[shortlisted rejected].include?(action)
      @application.update!(status: action)
    else
      raise ActionController::BadRequest, "Invalid application status"
    end
    @applications = Application.joins(room: :property).where(properties: { host_id: current_user.id })
                               .includes(:seeker, room: :property).order(created_at: :desc)
    @pending_count = @applications.pending_answer.count
    flash.now[:notice] = "Application updated."
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to applications_path, notice: "Application updated." }
    end
  rescue ActiveRecord::RecordInvalid => error
    redirect_to applications_path, alert: error.record.errors.full_messages.to_sentence
  end

  def withdraw
    application = Application.find_by!(id: params[:id], seeker_id: current_user&.id)
    if application.pending? || application.shortlisted?
      application.update!(status: :withdrawn)
      redirect_to listing_path(application.room), notice: "Application withdrawn."
    else
      redirect_to listing_path(application.room), alert: "This application can no longer be withdrawn."
    end
  end

  private

  def host_application
    Application.joins(room: :property).where(properties: { host_id: current_user&.id })
               .includes(:seeker, :visit, room: :property).find(params[:id])
  end

  def application_params
    params.require(:application).permit(:message, :move_in_date, :intended_stay_months)
  end
end
