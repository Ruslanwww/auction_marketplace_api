require "rails_helper"

RSpec.describe LotsController, type: :controller do
  let(:fields) do
    %i[id user_id title description current_price estimated_price
          image lot_start_time lot_end_time status]
  end

  describe "GET #index" do
    let(:params) { {} }
    subject { get :index, params: params }

    context "when user authorized" do
      login(:user)

      it "should status code 200" do
        subject
        expect(response).to have_http_status(200)
      end

      context "should return proper json" do
        let!(:progress_lots) { create_list :lot, 13, user: @user, status: :in_process }
        let!(:pending_lots) { create_list :lot, 5, user: @user }

        it "should return 10 articles without parameters" do
          subject
          expect(json.length).to eq(10)
        end

        it "should use serializer" do
          subject
          expect(json).to all include(*fields)
        end

        context "page 2" do
          let(:params) { { page: 2 } }

          it "should return 3 articles for page 2" do
            subject
            expect(json.length).to eq(3)
          end
        end
      end

      context "order" do
        let!(:old_lot) { create :lot, status: :in_process, created_at: 1.day.ago }
        let!(:newer_lot) { create :lot, status: :in_process, created_at: DateTime.current }

        it "should return lots in the proper order" do
          subject
          expect(json.pluck(:id)).to eq [newer_lot.id, old_lot.id]
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

  describe "GET #my_lots" do
    login(:user)
    let(:params) { {} }
    subject { get :my_lots, params: params }

    it "should status code 200" do
      subject
      expect(response).to have_http_status(200)
    end

    context "should return proper json" do
      let(:no_user_lot) { create :lot, status: :in_process }
      let(:no_user_lot2) { create :lot, status: :in_process }
      let!(:no_user_lot3) { create :lot }
      let!(:bid) { create :bid, lot: no_user_lot, user: @user }
      let!(:bid2) { create :bid, lot: no_user_lot2, user: @user }
      let!(:user_lots) { create_list :lot, 9, user: @user }
      let(:fields) { super() + [:my_lot] }

      it "should return 10 articles without parameters" do
        subject
        expect(json.length).to eq(10)
      end

      it "should return :my_lot 10 true" do
        subject
        my_lot_array = json.pluck(:my_lot)
        expect(my_lot_array.select { |my_lot|  my_lot }.count).to eq 9
      end

      it "should use serializer" do
        subject
        expect(json).to all include(*fields)
      end

      context "page 2" do
        let(:params) { { page: 2 } }

        it "should return 1 article for page 2" do
          subject
          expect(json.length).to eq(1)
        end
      end

      context "with created filter" do
        let(:params) { { filter: :created } }

        it "should return 9 articles" do
          subject
          expect(json.length).to eq(9)
        end
      end

      context "with participation filter" do
        let(:params) { { filter: :participation } }

        it "should return 2 articles" do
          subject
          expect(json.length).to eq(2)
        end
      end
    end

    context "order" do
      let!(:old_lot) { create :lot, user: @user, created_at: 1.day.ago }
      let!(:newer_lot) { create :lot, user: @user, created_at: DateTime.current }

      it "should return lots in the proper order" do
        subject
        expect(json.pluck(:id)).to eq [newer_lot.id, old_lot.id]
      end
    end
  end

  describe "GET #show" do
    login(:user)
    let(:lot) { create :lot, status: :in_process }
    let(:params) { { id: lot.id } }
    subject { get :show, params: params }

    context "when the record exists" do
      it "should status code 200" do
        subject
        expect(response).to have_http_status(200)
      end

      it "should return the lot" do
        subject
        expect(json).not_to be_empty
        expect(json[:id]).to eq(lot.id)
      end
    end

    context "when the record does not exist" do
      let(:params) { { id: 100 } }

      it "should return status code 404" do
        subject
        expect(response).to have_http_status(404)
      end

      it "should return a not found message" do
        subject
        expect(json).to eq error: "Couldn't find Lot with 'id'=100"
      end
    end

    context "should return proper json" do
      let(:fields) { super() + [:my_win] }
      before(:each) do
        lot.closed!
      end

      it "should use serializer" do
        subject
        expect(json).to include(*fields)
      end
    end

    context "when current user user is winner" do
      before(:each) do
        create(:bid, lot: lot, proposed_price: lot.current_price + 1.0)
        create(:bid, lot: lot, user: @user, proposed_price: lot.current_price + 2.0)
        lot.closed!
      end

      it "should my_win is true" do
        subject
        expect(json[:my_win]).to eq true
      end
    end

    context "when current user user is not winner" do
      before(:each) do
        create(:bid, lot: lot, user: @user, proposed_price: lot.current_price + 1.0)
        create(:bid, lot: lot, proposed_price: lot.current_price + 2.0)
        lot.closed!
      end

      it "should my_win is false" do
        subject
        expect(json[:my_win]).to eq false
      end
    end
  end

  describe "POST #create" do
    login(:user)
    let(:title) { "Valid title" }
    subject { post :create, params: { lot: attributes_for(:lot, title: title) } }

    context "with valid attributes" do
      it "creates a new lot" do
        expect { subject }.to change(Lot, :count).by(1)
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
      let(:title) { "" }

      it "does not save the new lot" do
        expect { subject }.to_not change(Lot, :count)
      end

      it "should status code 422" do
        is_expected.to have_http_status(422)
      end

      it "should contain right message" do
        subject
        expect(json).to eq error: "Validation failed: Title can't be blank"
      end
    end
  end

  describe "PUT #update" do
    let(:user) { create(:user) }
    let(:lot) { create :lot, user: user }
    let(:params) { { id: lot.id, lot: { title: "Title2" } } }
    before(:each) do
      login_by user
    end
    subject { put :update, params: params }

    context "with valid attributes" do
      it "changes lot attributes" do
        expect { subject }.to change { lot.reload.title }.to("Title2")
      end
    end

    context "with invalid attributes" do
      let(:params) { { id: lot.id, lot: { title: "" } } }

      it "does not change lot attributes" do
        expect { subject }.to_not change { lot.reload.title }
      end

      it "should status code 422" do
        is_expected.to have_http_status(422)
      end

      it "should contain right message" do
        subject
        expect(json).to eq error: "Validation failed: Title can't be blank"
      end
    end

    context "should return proper json" do
      it "should use serializer" do
        subject
        expect(json).to include(*fields)
      end
    end

    context "with status :in_process" do
      let(:lot) { create :lot, user: user, status: :in_process }

      it "does not change lot attributes" do
        subject
        lot.reload
        expect(lot.title).to_not eq("Title2")
      end
    end

    context "with status :closed" do
      let(:lot) { create :lot, user: user, status: :closed }

      it "does not change lot attributes" do
        subject
        lot.reload
        expect(lot.title).to_not eq("Title2")
      end
    end

    context "with not valid user" do
      let!(:user2) { create :user }
      let!(:user2_login) { login_by user2 }

      it "do not change with no owner" do
        subject
        lot.reload
        expect(lot.title).to_not eq("Title2")
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
  end

  describe "DELETE #destroy" do
    let(:user) { create(:user) }
    let!(:lot) { create :lot, user: user }
    before(:each) do
      login_by user
    end
    subject { delete :destroy, params: { id: lot.id } }

    it "deletes the lot" do
      expect { subject }.to change(Lot, :count).by(-1)
    end

    it "should return status code 204" do
      subject
      expect(response).to have_http_status(204)
    end

    context "with not valid user" do
      let!(:user2) { create :user }
      let!(:user2_login) { login_by user2 }

      it "do not change with no owner" do
        expect { subject }.to_not change(Lot, :count)
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

    context "with status :in_process" do
      let(:lot) { create :lot, status: :in_process, user: user }

      it "do not delete with :in_progress status" do
        subject
        expect(response).to have_http_status(401)
      end
    end

    context "with status :closed" do
      let(:lot) { create :lot, status: :closed, user: user }

      it "do not delete with :closed status" do
        subject
        expect(response).to have_http_status(401)
      end
    end
  end
end
