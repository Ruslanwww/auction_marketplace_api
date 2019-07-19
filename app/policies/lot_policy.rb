class LotPolicy < ApplicationPolicy
  def update?
    pending_lot_owner?
  end

  def destroy?
    pending_lot_owner?
  end

  private

    def pending_lot_owner?
      user == record.user && record.status == "pending"
    end
end
