require "rails_helper"

RSpec.describe LotsController, type: :controller do
  login(:user)

  describe "GET #index" do
    let(:params) { {} }
    subject { get :index, params: params }

    it "should status code 200" do
      subject
      expect(response).to have_http_status(200)
    end

    context "should return proper json" do
      let!(:progress_lots) { create_list :lot, 13, user: @user, status: :in_process }
      let!(:pending_lots) { create_list :lot, 5, user: @user }
      let(:fields) do
        %i[id user_id title description current_price estimated_price
          image lot_start_time lot_end_time status]
      end

      it "should return 10 articles without parameters" do
        subject
        expect(json.length).to eq(10)
      end

      context "page 2" do
        let(:params) { { page: 2 } }

        it "should return 3 articles for page 2" do
          subject
          expect(json.length).to eq(3)
        end
      end

      it "should use serializer" do
        subject
        expect(json.first.keys).to match_array(fields)
      end
    end

    it "should return lots in the proper order" do
      old_lot = create :lot, status: :in_process
      newer_lot = create :lot, status: :in_process
      subject
      expect(json.first[:id]).to eq(newer_lot.id)
      expect(json.last[:id]).to eq(old_lot.id)
    end
  end

  describe "GET #my_lots" do
    let(:params) { {} }
    subject { get :my_lots, params: params }

    it "should status code 200" do
      subject
      expect(response).to have_http_status(200)
    end

    context "should return proper json" do
      let!(:user_lots) { create_list :lot, 13, user: @user }
      let!(:no_user_lots) { create_list :lot, 5, user: create(:user) }
      let(:fields) do
        %i[id user_id title description current_price estimated_price
          image lot_start_time lot_end_time status my_lot]
      end

      it "should return 10 articles without parameters" do
        subject
        expect(json.length).to eq(10)
      end

      context "page 2" do
        let(:params) { { page: 2 } }

        it "should return 3 articles for page 2" do
          subject
          expect(json.length).to eq(3)
        end
      end

      it "should return :my_lot 10 true" do
        subject
        my_lot_array = json.pluck(:my_lot)
        expect(my_lot_array.select { |my_lot|  my_lot }.count).to eq 10
      end

      it "should use serializer" do
        subject
        expect(json.first.keys).to match_array(fields)
      end
    end

    it "should return lots in the proper order" do
      old_lot = create :lot, user: @user
      newer_lot = create :lot, user: @user
      subject
      expect(json.first[:id]).to eq(newer_lot.id)
      expect(json.last[:id]).to eq(old_lot.id)
    end
  end

  describe "GET #show" do
    let(:lot) { create :lot }
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
        expect(response.body).to match("{\"error\":\"Couldn't find Lot\"}")
      end
    end

    context "should return proper json" do
      let(:fields) do
        %i[id user_id title description current_price estimated_price
          image lot_start_time lot_end_time status bids]
      end

      it "should use serializer" do
        subject
        expect(json.keys).to match_array(fields)
      end
    end
  end

  describe "POST #create" do
    subject { post :create, params: { lot: attributes_for(:lot, title: title) } }

    context "with valid attributes" do
      let(:title) { "Valid title" }

      it "creates a new lot" do
        expect { subject }.to change(Lot, :count).by(1)
      end

      it "should status code 201" do
        is_expected.to have_http_status(201)
      end

      context "should return proper json" do
        let(:fields) do
          %i[id user_id title description current_price estimated_price
          image lot_start_time lot_end_time status]
        end

        it "should use serializer" do
          subject
          expect(json.keys).to match_array(fields)
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
    end
  end

  describe "PUT #update" do
    let(:lot) { create :lot, user: @user }
    let(:params) { { id: lot.id, lot: { title: "Title2" } } }
    subject { put :update, params: params }

    context "with valid attributes" do
      it "changes lot attributes" do
        subject
        lot.reload
        expect(lot.title).to eq("Title2")
      end
    end

    context "with invalid attributes" do
      let(:params) { { id: lot.id, lot: { title: "" } } }

      it "does not change lot attributes" do
        subject
        lot.reload
        expect(lot.title).to_not eq("")
      end
    end

    context "should return proper json" do
      let(:fields) do
        %i[id user_id title description current_price estimated_price
          image lot_start_time lot_end_time status]
      end

      it "should use serializer" do
        subject
        expect(json.keys).to match_array(fields)
      end
    end

    context "with status :in_process" do
      let(:lot) { create :lot, user: @user, status: :in_process }

      it "does not change lot attributes" do
        subject
        lot.reload
        expect(lot.title).to_not eq("Title2")
      end
    end

    context "with status :closed" do
      let(:lot) { create :lot, user: @user, status: :closed }

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
        expect(response.body).to match("You do not have permission to modify this lot")
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:lot) { create :lot, user: @user }
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
        expect(response.body).to match("You do not have permission to modify this lot")
      end
    end

    context "with status :in_process" do
      let(:lot) { create :lot, status: :in_process, user: @user }

      it "do not delete with :in_progress status" do
        subject
        expect(response).to have_http_status(401)
      end
    end

    context "with status :closed" do
      let(:lot) { create :lot, status: :closed, user: @user }

      it "do not delete with :in_progress status" do
        subject
        expect(response).to have_http_status(401)
      end
    end
  end
end
