class LotPolicy < ApplicationPolicy
  def update?
    pending_lot_owner?
  end

  def destroy?
    pending_lot_owner?
  end

  private

    def lot
      record
    end

    def pending_lot_owner?
      user == lot.user && lot.status == "pending"
    end
end
