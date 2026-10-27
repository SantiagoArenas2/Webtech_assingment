class ActingAsController < ApplicationController
  def update
    user = User.find(params[:user_id])
    cookies.signed[:acting_user_id] = {
      value: user.id, expires: 30.days.from_now, httponly: true, same_site: :lax
    }
    redirect_back fallback_location: root_path, notice: "You are now acting as #{user.name}."
  end
end
