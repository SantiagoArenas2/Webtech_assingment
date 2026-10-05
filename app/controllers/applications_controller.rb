class ApplicationsController < ApplicationController
  def index
    @applications = Application.includes(:seeker, room: :property).order(created_at: :desc)
  end

  def show
    @application = Application.includes(:seeker, :visit, room: :property).find(params[:id])
  end
end
