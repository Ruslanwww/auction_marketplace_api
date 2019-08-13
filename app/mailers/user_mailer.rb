class UserMailer < ApplicationMailer
  def email_for_winner(lot)
    user = lot.winner_bid.user
    @data = { title: lot.title, firstname: user.firstname }
    mail(to: user.email, subject: "You won a lot #{lot.title}")
  end

  def email_for_owner(lot)
    user = lot.user
    @data = { firstname: user.firstname, current_price: lot.current_price, bids_present: lot.bids.present? }
    mail(to: user.email, subject: "Your lot #{lot.title} is closed")
  end

  def email_for_seller(order)
    user = order.lot.user
    @data = { title: order.lot.title, firstname: user.firstname }
    mail(to: user.email, subject: "An order has been created for your lot #{@data[:title]}")
  end

  def email_about_sending(order)
    user = order.bid.user
    @data = { title: order.lot.title, firstname: user.firstname }
    mail(to: user.email, subject: "Your order #{@data[:title]} has been sent successfully")
  end

  def email_about_delivery(order)
    user = order.lot.user
    @data = { title: order.lot.title, firstname: user.firstname }
    mail(to: user.email, subject: "Your lot #{@data[:title]} has been successfully received by the buyer")
  end
end
