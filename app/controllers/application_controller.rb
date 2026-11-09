class ApplicationController < ActionController::Base
  include Authentication
  include Pundit::Authorization

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :current_user
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def current_user
    Current.user || resume_session&.user
  end

  def user_not_authorized
    redirect_to root_path, alert: "You are not allowed to perform that action."
  end

  def pundit_user
    current_user
  end
end
