##############################################################################
#
# Handles omniauth callbacks and authorizes users via social networks.
#
##############################################################################
class CallbacksController < Devise::OmniauthCallbacksController
  before_action :fill_user

  # def twitter
  # end

  # def google
  # end

  def facebook
    render nothing: true
  end

  # def vkontakte
  # end

  private

  def fill_user
    @user = User.from_omniauth(request.env['omniauth.auth'])
    sign_in @user
  end
end