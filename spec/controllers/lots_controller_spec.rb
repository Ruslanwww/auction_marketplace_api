require "rails_helper"

RSpec.describe LotsController, type: :controller do
  login(:user)

  describe "GET #index" do
    it "should status code 200" do
      get :index
      expect(response).to have_http_status(200)
    end

    context "should return proper json" do
      before(:each) do
        create_list :lot, 13, user: @user, status: :in_process
        create_list :lot, 5, user: @user
      end

      it "should return 10 articles without parameters" do
        get :index
        expect(json.length).to eq(10)
      end

      it "should return 3 articles for page 2" do
        get :index, params: { page: 2 }
        expect(json.length).to eq(3)
      end
    end

    it "should return lots in the proper order" do
      old_lot = create :lot, status: :in_process
      newer_lot = create :lot, status: :in_process
      get :index
      expect(json.first[:id]).to eq(newer_lot.id)
      expect(json.last[:id]).to eq(old_lot.id)
    end
  end

  describe "GET #my_lots" do
    it "should status code 200" do
      get :my_lots
      expect(response).to have_http_status(200)
    end

    context "should return proper json" do
      before(:each) do
        create_list :lot, 13, user: @user
        create_list :lot, 5, user: create(:user)
      end

      it "should return 10 articles without parameters" do
        get :my_lots
        expect(json.length).to eq(10)
      end

      it "should return 3 articles for page 2" do
        get :my_lots, params: { page: 2 }
        expect(json.length).to eq(3)
      end

      it "should return :my_lot 10 true" do
        get :my_lots
        my_lot_array = json.pluck(:my_lot)
        expect(my_lot_array.select { |my_lot|  my_lot }.count).to eq 10
      end
    end

    it "should return lots in the proper order" do
      old_lot = create :lot, user: @user
      newer_lot = create :lot, user: @user
      get :my_lots
      expect(json.first[:id]).to eq(newer_lot.id)
      expect(json.last[:id]).to eq(old_lot.id)
    end
  end

  describe "GET #show" do
    let(:lot) { create :lot }

    context "when the record exists" do
      before(:each) do
        get :show, params: { id: lot.id }
      end
      it "should status code 200" do
        expect(response).to have_http_status(200)
      end

      it "should return the lot" do
        expect(json).not_to be_empty
        expect(json[:id]).to eq(lot.id)
      end
    end

    context "when the record does not exist" do
      before(:each) do
        get :show, params: { id: 100 }
      end

      it "should return status code 404" do
        expect(response).to have_http_status(404)
      end

      it "should return a not found message" do
        expect(response.body).to match("{\"error\":\"Couldn't find Lot\"}")
      end
    end
  end

  describe "POST #create" do
    subject { post :create, params: { lot: attributes_for(:lot, title: @title) } }

    context "with valid attributes" do
      before(:each) do
        @title = "Valid title"
      end

      it "creates a new lot" do
        expect { subject }.to change(Lot, :count).by(1)
      end

      it "should status code 201" do
        subject
        is_expected.to have_http_status(201)
      end
    end

    context "with invalid attributes" do
      before(:each) do
        @title = ""
      end

      it "does not save the new lot" do
        expect { subject }.to_not change(Lot, :count)
      end

      it "should status code 422" do
        subject
        is_expected.to have_http_status(422)
      end
    end
  end

  describe "PUT #update" do
    before :each do
      @lot = create :lot, title: "Title1", user: @user
    end
    subject { put :update, params: { id: @lot.id, lot: { title: "Title2" } } }

    context "with valid attributes" do
      it "changes lot attributes" do
        subject
        @lot.reload
        expect(@lot.title).to eq("Title2")
      end
    end

    context "with invalid attributes" do
      it "does not change lot attributes" do
        put :update, params: { id: @lot.id, lot: { title: "" } }
        @lot.reload
        expect(@lot.title).to_not eq("")
      end
    end

    context "with status :in_process" do
      before :each do
        @lot = create :lot, title: "Title1", user: @user, status: :in_process
      end

      it "does not change lot attributes" do
        subject
        @lot.reload
        expect(@lot.title).to_not eq("Title2")
      end
    end

    context "with status :closed" do
      before :each do
        @lot = create :lot, title: "Title1", user: @user, status: :closed
      end

      it "does not change lot attributes" do
        subject
        @lot.reload
        expect(@lot.title).to_not eq("Title2")
      end
    end

    context "with not valid user" do
      before(:each) do
        @user2 = create :user
        login_by @user2
      end

      it "do not change with no owner" do
        subject
        @lot.reload
        expect(@lot.title).to_not eq("Title2")
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
    before :each do
      @lot = create :lot, user: @user
    end
    subject { delete :destroy, params: { id: @lot.id } }

    it "deletes the lot" do
      expect { subject }.to change(Lot, :count).by(-1)
    end

    it "should return status code 204" do
      subject
      expect(response).to have_http_status(204)
    end

    context "with not valid user" do
      before(:each) do
        @user2 = create :user
        login_by @user2
      end

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
      before :each do
        @lot = create :lot, user: @user, status: :in_process
      end

      it "do not delete with :in_progress status" do
        subject
        expect(response).to have_http_status(401)
      end
    end

    context "with status :closed" do
      before :each do
        @lot = create :lot, user: @user, status: :closed
      end

      it "do not delete with :in_progress status" do
        subject
        expect(response).to have_http_status(401)
      end
    end
  end
end
