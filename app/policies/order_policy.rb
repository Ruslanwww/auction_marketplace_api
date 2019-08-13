class OrderPolicy < ApplicationPolicy
  def show?
    user == bid.user || user == lot.user
  end

  def create?
    lot.winner_bid.user == user
  end

  def update?
    (record.sent? && bid.user == user) || (record.pending? && (bid.user == user || lot.user == user))
  end

  private
    def lot
      record.lot
    end

    def bid
      record.bid
    end
end
