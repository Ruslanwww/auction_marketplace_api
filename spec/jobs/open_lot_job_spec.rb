require "rails_helper"

RSpec.describe OpenLotJob, type: :job do
  let(:param) { 1 }
  subject(:job) { described_class.perform_later param }

  it "queues the job" do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it "matches with enqueued job" do
    expect {
      described_class.set(wait_until: Date.tomorrow.noon).perform_later(param)
    }.to have_enqueued_job.at(Date.tomorrow.noon)
  end

  it "is in default queue" do
    expect(described_class.new.queue_name).to eq("default")
  end

  describe "#perform" do
    let(:lot_status) { :pending }
    let(:lot) { create :lot, status: lot_status }
    subject { described_class.new.perform lot.id }

    it "submit service was launched" do
      expect(Lot).to receive(:find).with(lot.id).and_return(lot)
      expect(lot).to receive(:in_process!)
      subject
    end

    context "with closed status" do
      let(:lot_status) { :closed }
      subject { described_class.new.perform lot.id }

      it "submit service was launched" do
        expect(Lot).to receive(:find).with(lot.id).and_return(lot)
        expect(lot).to_not receive(:in_process!)
        subject
      end
    end
  end
end
