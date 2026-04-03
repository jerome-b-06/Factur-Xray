require 'rails_helper'

RSpec.describe Invoice, type: :model do
  let(:company) { Company.create!(name: "CompanyTest", siret: 321654, siren: 3216, vat_number: "FR6776578658765") }
  let(:valid_attributes) { { company: company,
                             status: "pending",
                             number: "AA-123456",
                             issue_date: Date.yesterday,
                             due_date: Date.yesterday + 1.month,
                             invoice_items_attributes: [
                               { description: "Produit_1", quantity: 1, unit_price: 100.0, vat_rate: 20.0 },
                               { description: "Produit_2", quantity: 10, unit_price: 10.0, vat_rate: 20.0 }
                             ]
  } }
  subject {
    described_class.new(valid_attributes)
  }

  describe "associations" do
    it "belongs to a company" do
      expect(subject.company).to eq(company)
    end

    it "is invalid without a company" do
      subject.company = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:company]).to include(I18n.t('errors.messages.required'))
    end
  end

  describe "validations" do
    it "is valid with valid attributes" do
      expect(subject).to be_valid
    end

    it "is not valid with an unknown value of status" do
      subject.status = "Unknown"
      expect(subject).not_to be_valid
    end

    it "is not valid without a number" do
      subject.number = nil
      expect(subject).not_to be_valid
    end

    it "is not valid without an issue date" do
      subject.issue_date = nil
      expect(subject).not_to be_valid
    end

    it "is not valid without a due date" do
      subject.due_date = nil
      expect(subject).not_to be_valid
    end
  end

  describe "callbacks" do
    describe "#calculate_total_ttc" do
      it "calculates the correct TTC amount before saving" do
        subject.save
        expect(subject.total_ttc).to eq(240)
      end
    end
  end
end
