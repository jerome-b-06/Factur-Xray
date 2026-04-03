class InvoiceItem < ApplicationRecord
  belongs_to :invoice

  validates :description, :quantity, :unit_price, :vat_rate, presence: true

  before_save :update_total

  private

  def update_total
    self.total_ht = quantity * unit_price
    self.total_vat = total_ht * (vat_rate / 100)
    self.total_ttc = total_ht + total_vat
  end

end
