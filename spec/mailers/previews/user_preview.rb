# Preview all emails at http://localhost:3000/rails/mailers/user
class UserPreview < ActionMailer::Preview
  def email_for_winner
    UserMailer.email_for_winner(FactoryBot.create(:bid).lot)
  end

  def email_for_owner
    UserMailer.email_for_owner(FactoryBot.create(:lot))
  end

  def email_for_seller
    UserMailer.email_for_seller(my_order)
  end

  def email_about_sending
    UserMailer.email_about_sending(my_order)
  end

  def email_about_delivery
    UserMailer.email_about_delivery(my_order)
  end

  private
    def my_order
      lot = FactoryBot.create(:lot, status: :in_process)
      bid = FactoryBot.create(:bid, lot: lot)
      lot.closed!
      FactoryBot.create(:order, lot: lot, bid: bid)
    end
end
