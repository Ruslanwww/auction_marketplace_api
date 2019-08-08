require "rails_helper"

RSpec.describe BidBroadcastJob, type: :job do
  let(:param) { 1 }
  subject(:job) { described_class.perform_later param }

  it "queues the job" do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it "is in default queue" do
    expect(described_class.new.queue_name).to eq("default")
  end

  describe "#perform" do
    let(:bid) { create :bid }

    it "should broadcasts bid" do
      expect { described_class.perform_now(bid.id) }
          .to have_broadcasted_to("bids_for_lot_#{bid.lot_id}").from_channel(BidsChannel)
    end
  end
end
