class OpenLotJob < ApplicationJob
  queue_as :default

  def perform(id)
    lot = Lot.find(id)
    lot.in_process! if lot.pending?
  end
end
