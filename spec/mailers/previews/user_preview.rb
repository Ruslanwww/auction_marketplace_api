# Preview all emails at http://localhost:3000/rails/mailers/user
class UserPreview < ActionMailer::Preview
  def email_for_winner
    UserMailer.email_for_winner(FactoryBot.create(:bid).lot)
  end

  def email_for_owner
    UserMailer.email_for_owner(FactoryBot.create(:lot))
  end
end
