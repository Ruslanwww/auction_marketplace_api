class UserMailer < ApplicationMailer
  def email_for_winner(lot)
    @lot = lot
    @user = lot.winner_bid.user
    mail(to: @user.email, subject: "You won a lot #{lot.title}")
  end

  def email_for_owner(lot)
    @lot = lot
    @user = lot.user
    mail(to: @user.email, subject: "Your lot #{lot.title} is closed")
  end
end
