require "rails_helper"

RSpec.describe OpenLotJob, type: :job do
  let(:param) { 1 }
  subject(:job) { described_class.perform_later(param) }

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
end
