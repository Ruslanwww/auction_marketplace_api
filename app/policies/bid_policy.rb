class BidPolicy < ApplicationPolicy
  def create?
    user != record.lot.user
  end
end
