require "rails_helper"

RSpec.describe BidsController, type: :controller do
  let(:fields) do
    %i[id proposed_price created_at]
  end

  describe "GET #index" do
    let(:lot) { create :lot, status: :in_process }
    let(:params) { { lot_id: lot.id } }
    subject { get :index, params: params }

    context "when user authorized" do
      login(:user)

      it "should status code 200" do
        subject
        expect(response).to have_http_status(200)
      end

      context "should return proper json" do
        let(:fields) { super() + [:customer] }
        let!(:bid1) { create :bid, lot: lot, proposed_price: 15.0 }
        let!(:bid2) { create :bid, lot: lot, proposed_price: 20.0 }

        it "should return 2 bids" do
          subject
          expect(json.length).to eq(2)
        end

        it "should return bids in the proper order" do
          subject
          expect(json.pluck(:id)).to eq [bid2.id, bid1.id]
        end

        it "should use serializer" do
          subject
          expect(json).to all include(*fields)
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

  describe "POST #create" do
    let(:lot) { create :lot, status: :in_process }
    let(:proposed_price) { 15.0 }
    subject { post :create, params: { bid: attributes_for(:bid, proposed_price: proposed_price, lot_id: lot.id) } }

    context "when user authorized" do
      login(:user)

      context "with valid attributes" do
        it "creates a new bid" do
          expect { subject }.to change(Bid, :count).by(1)
        end

        it "should status code 201" do
          is_expected.to have_http_status(201)
        end

        context "should return proper json" do
          it "should use serializer" do
            subject
            expect(json).to include(*fields)
          end
        end
      end

      context "with invalid attributes" do
        let(:proposed_price) { 2.0 }

        it "does not save the new bid" do
          expect { subject }.to_not change(Bid, :count)
        end

        it "should status code 422" do
          is_expected.to have_http_status(422)
        end

        it "should contain right message" do
          subject
          expect(json).to eq error: "Validation failed: Proposed price must be greater than current price"
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

  describe "DELETE #destroy" do
    let(:user) { create :user }
    let(:bid_creator) { create :user }
    let!(:bid) { create :bid, user: bid_creator }
    subject { delete :destroy, params: { id: bid.id } }

    context "when user authorized" do
      let!(:user_login) { login_by bid_creator }

      it "should delete the bid" do
        expect { subject }.to change(Bid, :count).by(-1)
      end

      it "should return status code 204" do
        subject
        expect(response).to have_http_status(204)
      end

      context "with not valid user" do
        let!(:user2) { create :user }
        let!(:user2_login) { login_by user2 }

        it "do not delete with no owner" do
          expect { subject }.to_not change(Bid, :count)
        end

        it "should status code 401" do
          subject
          expect(response).to have_http_status(401)
        end

        it "should error message" do
          subject
          expect(json).to eq error: "You are not have permission for this action"
        end
      end

      context "with status :pending" do
        let!(:lot_change_status) { bid.lot.status = "pending" }

        it "do not delete with :pending status" do
          bid.lot.save
          subject
          expect(response).to have_http_status(401)
        end
      end

      context "with status :closed" do
        let!(:lot_change_status) { bid.lot.status = "closed" }

        it "do not delete with :closed status" do
          bid.lot.save
          subject
          expect(response).to have_http_status(401)
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
end