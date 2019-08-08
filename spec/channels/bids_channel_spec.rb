require "rails_helper"

RSpec.describe BidsChannel, type: :channel do
  let(:lot) { create :lot }
  let(:bid) { create :bid }

  it "rejects when no lot id" do
    subscribe
    expect(subscription).to be_rejected
  end

  it "subscribes to a stream when lot id is provided" do
    subscribe(lot_id: lot.id)

    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_from "bids_for_lot_#{lot.id}"
  end
end
