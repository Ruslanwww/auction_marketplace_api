require "rails_helper"

RSpec.describe "Auth", type: :request do
  describe "POST /auth" do
    let(:params) { attributes_for(:user) }
    subject { post "/auth", params: params }

    context "with valid attributes" do
      it "should status code 200" do
        subject
        expect(response).to have_http_status(200)
      end

      it "should create a new user" do
        expect { subject }.to change(User, :count).by(1)
      end

      it "should send a confirmation email" do
        expect { subject }.to change(Devise.mailer.deliveries, :count).by(1)
      end
    end

    context "with invalid attributes" do
      let(:params) { attributes_for(:user, password: "123") }

      it "should status code 422" do
        subject
        expect(response).to have_http_status(422)
      end

      it "should not create a new user" do
        expect { subject }.to_not change(User, :count)
      end

      it "should not send a confirmation email" do
        expect { subject }.to_not change(Devise.mailer.deliveries, :count)
      end
    end
  end

  describe "POST /auth/sign_in" do
    let(:user) { create(:user) }
    let(:params) { { email: user.email, password: "123456" } }
    subject { post "/auth/sign_in", params: params }

    context "with valid attributes" do
      it "should status code 200" do
        subject
        expect(response).to have_http_status(200)
      end
    end

    context "with invalid password" do
      let(:params) { { email: user.email, password: "123" } }

      it "should status code 401" do
        subject
        expect(response).to have_http_status(401)
      end
    end

    context "with invalid email" do
      let(:params) { { email: "email@gmal.com", password: "123456" } }

      it "should status code 401" do
        subject
        expect(response).to have_http_status(401)
      end
    end
  end

  describe "POST /auth/sign_out" do
    let(:headers) { create(:user).create_new_auth_token }
    subject { delete "/auth/sign_out", headers: headers }

    context "when headers present" do
      it "should status code 200" do
        subject
        expect(response).to have_http_status(200)
      end
    end

    context "when headers are not present" do
      let(:headers) { {} }

      it "should not be successful" do
        subject
        expect(response).to_not be_successful
      end
    end
  end
end
