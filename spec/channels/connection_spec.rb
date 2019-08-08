require "rails_helper"

RSpec.describe ApplicationCable::Connection, type: :channel do
  let(:user) { create :user }
  let(:headers) { user.create_new_auth_token }

  it "rejects connection" do
    expect { connect "/cable" }.to have_rejected_connection
  end

  it "successfully connects" do
    connect "/cable", headers: headers
    expect(connection.current_user).to eq user
  end
end
