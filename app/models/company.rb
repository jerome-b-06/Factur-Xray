class Company < ApplicationRecord
  has_many :invoices, dependent: :destroy

  validates :name, :siret, :siren, :vat_number, presence: true

  has_rich_text :invoice_template

  def total_invoiced
    self.invoices.sum(&:total_ttc)
  end

  def invoices_count
    self.invoices.count
  end

end
