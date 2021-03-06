# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def password_reset(user, reset_token)
    @user = user
    @reset_token = reset_token
    mail from: 'nova.password.reset@mf2018.youki.io', to: user.email, subject: 'Password reset'
  end
end
