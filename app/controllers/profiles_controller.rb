class ProfilesController < ApplicationController
  def edit
    @user = current_user
    authorize @user, :update?
  end

  def update
    @user = current_user
    authorize @user, :update?
    if @user.update(profile_params)
      redirect_to edit_profile_path, notice: "Profile updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:user).permit(:name, :email, :contact_details, :bio)
  end
end
