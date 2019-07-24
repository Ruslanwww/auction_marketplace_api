class BidPolicy < ApplicationPolicy
  def destroy?
    user == record.user && record.lot.in_process?
  end
end
