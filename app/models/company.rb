class Company < ApplicationRecord
  has_many :invoices, dependent: :destroy

  validates :name, :siret, :siren, :vat_number, presence: true

end
