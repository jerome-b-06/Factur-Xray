class Invoice < ApplicationRecord
  belongs_to :company

  before_save :calculate_total_ttc

  validates :number, :issue_date, :due_date, presence: true
  validates :vat_rate, numericality: { greater_than_or_equal_to: 0 }, allow_nil: false
  validates :total_ht, numericality: { greater_than_or_equal_to: 0 }, allow_nil: false

  enum :status, { pending: "pending", processed: "processed", error: "error" }, validate: true

  private

  def calculate_total_ttc
    self.total_ttc = self.total_ht * (1 + self.vat_rate / 100)
  end
end
