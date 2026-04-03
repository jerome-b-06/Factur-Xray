class Invoice < ApplicationRecord
  belongs_to :company
  has_many :invoice_items, dependent: :destroy

  after_save :generate_pdf, unless: :skip_pdf_generation

  validates :number, :issue_date, :due_date, presence: true

  enum :status, { draft: "draft", sent: "sent", paid: "paid" }, validate: true

  has_one_attached :pdf_invoice

  # Permet d'ajouter des lignes directement depuis le formulaire de la facture
  accepts_nested_attributes_for :invoice_items, allow_destroy: true

  attr_accessor :skip_pdf_generation

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

  def generate_pdf
    SavePdfInvoiceJob.perform_later(self) if self.editable?
  end

end
