require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "email_for_winner" do
    let(:lot) { create(:lot, status: :in_process) }
    let!(:bid) { create(:bid, lot: lot) }
    let(:mail) { described_class.email_for_winner(lot).deliver_now }

    it "renders the subject" do
      expect(mail.subject).to eq("You won a lot #{lot.title}")
    end

    it "renders the receiver email" do
      expect(mail.to).to eq([bid.user.email])
    end

    it "renders the sender email" do
      expect(mail.from).to eq(["auction@gmail.com"])
    end

    it "assigns @firstname" do
      expect(mail.body.encoded).to match(bid.user.firstname)
    end
  end

  describe "email_for_owner" do
    let(:lot) { create(:lot, status: :in_process) }
    let(:mail) { described_class.email_for_owner(lot).deliver_now }

    it "renders the subject" do
      expect(mail.subject).to eq("Your lot #{lot.title} is closed")
    end

    it "renders the receiver email" do
      expect(mail.to).to eq([lot.user.email])
    end

    it "renders the sender email" do
      expect(mail.from).to eq(["auction@gmail.com"])
    end

    context "when bids present" do
      before(:each) do
        create(:bid, lot: lot)
      end

      it "assigns @current_price" do
        expect(mail.body.encoded).to match(lot.current_price.to_s)
      end
    end

    context "when bids not present" do
      it "should return correct text" do
        expect(mail.body.encoded).to match("Unfortunately, there are no bids on your lot")
      end
    end
  end

  describe "email_for_seller" do
    let(:lot) { create :lot, status: :in_process }
    let!(:bid) { create :bid, lot: lot }
    before(:each) do
      lot.closed!
    end
    let!(:order) { create :order, lot: lot, bid: bid }
    let(:mail) { described_class.email_for_seller(order).deliver_now }

    it "renders the subject" do
      expect(mail.subject).to eq("An order has been created for your lot #{lot.title}")
    end

    it "renders the receiver email" do
      expect(mail.to).to eq([lot.user.email])
    end

    it "renders the sender email" do
      expect(mail.from).to eq(["auction@gmail.com"])
    end

    it "assigns @firstname" do
      expect(mail.body.encoded).to match(lot.user.firstname)
    end
  end

  describe "email_about_sending" do
    let(:lot) { create :lot, status: :in_process }
    let!(:bid) { create :bid, lot: lot }
    before(:each) do
      lot.closed!
    end
    let!(:order) { create :order, lot: lot, bid: bid }
    let(:mail) { described_class.email_about_sending(order).deliver_now }

    it "renders the subject" do
      expect(mail.subject).to eq("Your order #{lot.title} has been sent successfully")
    end

    it "renders the receiver email" do
      expect(mail.to).to eq([bid.user.email])
    end

    it "renders the sender email" do
      expect(mail.from).to eq(["auction@gmail.com"])
    end

    it "assigns @firstname" do
      expect(mail.body.encoded).to match(bid.user.firstname)
    end
  end

  describe "email_about_delivery" do
    let(:lot) { create :lot, status: :in_process }
    let!(:bid) { create :bid, lot: lot }

    before(:each) do
      lot.closed!
    end

    let!(:order) { create :order, lot: lot, bid: bid }
    let(:mail) { described_class.email_about_delivery(order).deliver_now }

    it "renders the subject" do
      expect(mail.subject).to eq("Your lot #{lot.title} has been successfully received by the buyer")
    end

    it "renders the receiver email" do
      expect(mail.to).to eq([lot.user.email])
    end

    it "renders the sender email" do
      expect(mail.from).to eq(["auction@gmail.com"])
    end

    it "assigns @firstname" do
      expect(mail.body.encoded).to match(lot.user.firstname)
    end
  end
end
