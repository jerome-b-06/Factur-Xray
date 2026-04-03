class Invoice < ApplicationRecord
  belongs_to :company
  has_many :invoice_items, dependent: :destroy

  before_save :calculate_total_ttc

  validates :number, :issue_date, :due_date, presence: true

  enum :status, { draft: "draft", sent: "sent", paid: "paid" }, validate: true

  has_one_attached :pdf_invoice

  # Permet d'ajouter des lignes directement depuis le formulaire de la facture
  accepts_nested_attributes_for :invoice_items, allow_destroy: true

  def company_name
    company&.name
  end

  def company_vat_number
    company&.vat_number
  end

  def total_ht
    invoice_items.sum(&:total_ht)
  end

  def total_vat
    invoice_items.sum(&:total_vat)
  end

  def total_ttc
    total_ht + total_vat
  end

  def editable?
    draft?
  end

  private

  def calculate_total_ttc
    self.total_ttc = self.total_ht * (1 + self.vat_rate / 100)
  end

end
