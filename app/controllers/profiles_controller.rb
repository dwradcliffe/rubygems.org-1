class ProfilesController < ApplicationController
  before_action :redirect_to_root, unless: :signed_in?, except: :show

  def edit
  end

  def show
    @user           = User.find_by_slug!(params[:id])
    rubygems        = @user.rubygems_downloaded
    @rubygems       = rubygems.slice!(0, 10)
    @extra_rubygems = rubygems
  end

  def update
    if current_user.update_attributes(params_user)
      if current_user.email_reset
        sign_out
        flash[:notice] = "You will receive an email within the next few " \
                         "minutes. It contains instructions for reconfirming " \
                         "your account with your new email address."
        redirect_to_root
      else
        flash[:notice] = "Your profile was updated."
        redirect_to edit_profile_path
      end
    else
      render :edit
    end
  end

  def delete
    @only_owner_gems = current_user.only_owner_gems
    @multi_owner_gems = current_user.rubygems_downloaded - @only_owner_gems
  end

  def destroy
    if User.authenticate(current_user.email, params[:user][:password]) && current_user.destroy
      flash[:notice] = t '.successful_flash'
      redirect_to_root
    else
      flash[:notice] = t '.unsuccessful_flash'
      redirect_to edit_profile_path
    end
  end

  private

  def params_user
    params.require(:user).permit(*User::PERMITTED_ATTRS)
  end
end
