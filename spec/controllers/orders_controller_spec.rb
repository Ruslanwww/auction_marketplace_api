require "rails_helper"

RSpec.describe OrdersController, type: :controller do
  let(:fields) do
    %i[id arrival_location arrival_type status created_at updated_at]
  end

  describe "#show" do
    login(:user)

    let(:lot) { create :lot, status: :in_process, user: @user }
    let!(:bid) { create :bid, lot: lot }
    let(:params) { { lot_id: lot.id } }

    before(:each) do
      lot.closed!
    end

    let!(:order) { create :order, lot: lot, bid: bid }

    subject { get :show, params: params }

    it "should use serializer" do
      subject
      expect(json).to include(*fields)
    end

    context "when the record exists" do
      it "should status code 200" do
        subject
        expect(response).to have_http_status(200)
      end

      it "should return the order" do
        subject
        expect(json).not_to be_empty
        expect(json[:id]).to eq(order.id)
      end
    end

    context "when the record does not exist" do
      let(:params) { { lot_id: 100 } }

      it "should return status code 404" do
        subject
        expect(response).to have_http_status(404)
      end

      it "should return a not found message" do
        subject
        expect(json).to eq error: "Couldn't find Order"
      end
    end

    context "when current user is not lot or order creator" do
      before(:each) do
        lot.update! user: create(:user)
      end

      it "should contain right message" do
        subject
        expect(json).to eq error: "You are not have permission for this action"
      end
    end
  end

  describe "#create" do
    let(:user) { create :user }
    let(:lot) { create :lot, status: :in_process }
    let(:location) { "location" }

    before(:each) do
      create(:bid, lot: lot, user: user)
      lot.closed!
    end

    subject { post :create, params: { order: { arrival_location: location, arrival_type: :royal_mail },
                                      lot_id: lot.id } }

    context "when user authorized" do
      before(:each) do
        login_by user
      end

      context "with valid attributes" do
        it "creates a new order" do
          expect { subject }.to change(Order, :count).by(1)
        end

        it "should status code 201" do
          is_expected.to have_http_status(201)
        end

        it "should use serializer" do
          subject
          expect(json).to include(*fields)
        end

        it "should return proper json" do
          subject
          expect(json[:arrival_location]).to eq("location")
          expect(json[:arrival_type]).to eq("royal_mail")
        end
      end

      context "with invalid attributes" do
        let(:location) { "" }

        it "does not save the new order" do
          expect { subject }.to_not change(Order, :count)
        end

        it "should status code 422" do
          is_expected.to have_http_status(422)
        end

        it "should contain right message" do
          subject
          expect(json).to eq error: "Validation failed: Arrival location can't be blank"
        end
      end
    end

    context "when user not authorized" do
      it "should status code 401" do
        subject
        expect(response).to have_http_status(401)
      end

      it "should contain right message" do
        subject
        expect(json).to eq errors: ["You need to sign in or sign up before continuing."]
      end
    end
  end

  describe "#update" do
    login :user

    let(:bid_creator) { create :user }
    let(:lot) { create :lot, status: :in_process, user: @user }
    let!(:bid) { create :bid, lot: lot, user: bid_creator }
    let(:params) { { lot_id: lot.id } }
    let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }

    before(:each) do
      lot.closed!
    end

    let!(:order) { create :order, lot: lot, bid: bid }

    subject { put :update, params: params }

    context "when order status :pending and current user is order creator" do
      let(:params) { { lot_id: lot.id, order: { arrival_location: "new_location" } } }
      before(:each) do
        login_by bid_creator
      end

      it "should use serializer" do
        subject
        expect(json).to include(*fields)
      end

      context "with valid attributes" do
        it "changes order attributes" do
          expect { subject }.to change { order.reload.arrival_location }.to("new_location")
        end
      end

      context "with invalid attributes" do
        let(:params) { { lot_id: lot.id, order: { arrival_location: "" } } }

        it "does not change lot attributes" do
          expect { subject }.to_not change { order.reload.arrival_location }
        end

        it "should status code 422" do
          is_expected.to have_http_status(422)
        end

        it "should contain right message" do
          subject
          expect(json).to eq error: "Validation failed: Arrival location can't be blank"
        end
      end
    end

    context "when order status :pending and current user is lot owner" do
      it "should status code 200" do
        is_expected.to have_http_status(200)
      end

      it "changes order status to :sent" do
        expect { subject }.to change { order.reload.status }.to("sent")
      end

      it "should email queues the job" do
        expect(UserMailer).to receive(:email_about_sending).and_return(message_delivery)
        allow(message_delivery).to receive(:deliver_later)
        subject
      end
    end

    context "when order status :sent and current user is order creator" do
      before(:each) do
        order.sent!
        login_by bid_creator
      end

      it "should status code 200" do
        is_expected.to have_http_status(200)
      end

      it "changes order status to :sent" do
        expect { subject }.to change { order.reload.status }.to("delivered")
      end

      it "should email queues the job" do
        expect(UserMailer).to receive(:email_about_delivery).and_return(message_delivery)
        allow(message_delivery).to receive(:deliver_later)
        subject
      end
    end

    context "when current user is not lot owner or order creator" do
      let(:new_user) { create(:user) }

      before(:each) do
        login_by new_user
      end

      it "should status code 401" do
        is_expected.to have_http_status(401)
      end

      it "should contain right message" do
        subject
        expect(json).to eq error: "You are not have permission for this action"
      end
    end
  end
end
