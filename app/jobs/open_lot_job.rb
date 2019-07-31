class OpenLotJob < ApplicationJob
  queue_as :default

  def perform(id)
    lot = Lot.find(id)
    lot.update! status: :in_process if lot.pending?
  end
end
