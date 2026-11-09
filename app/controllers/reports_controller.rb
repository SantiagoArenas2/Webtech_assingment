class ReportsController < ApplicationController
  def index
    authorize Report, :index?
    @reports = policy_scope(Report).includes(:reporter, room: :property).order(created_at: :desc)
  end

  def create
    room = Room.find(params[:listing_id])
    @report = Report.new(room: room, reporter: current_user, reason: report_params[:reason])
    authorize @report, :create?
    if @report.save
      redirect_to listing_path(room), notice: "Listing reported for moderator review."
    else
      redirect_to listing_path(room), alert: @report.errors.full_messages.to_sentence
    end
  end

  def resolve
    @report = Report.find(params[:id])
    authorize @report, :resolve?
    status = params.require(:report).permit(:status)[:status]
    unless status.in?(%w[dismissed actioned])
      return redirect_to reports_path, alert: "Choose a valid resolution."
    end

    @report.update!(status: status, resolver: current_user, resolved_at: Time.current)
    redirect_to reports_path, notice: "Report resolved."
  rescue ActiveRecord::RecordInvalid => error
    redirect_to reports_path, alert: error.record.errors.full_messages.to_sentence
  end

  private

  def report_params
    params.require(:report).permit(:reason)
  end
end
