class InvoiceValidation < ApplicationRecord
  has_one_attached :file

  validates :file, presence: true

  def valid_invoice?
    status === "valid"
  end
end
