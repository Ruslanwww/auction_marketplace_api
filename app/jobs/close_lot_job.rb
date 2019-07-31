class CloseLotJob < ApplicationJob
  queue_as :default

  def perform(id)
    lot = Lot.find(id)
    lot.close! if lot.in_process?
  end
end
