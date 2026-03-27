require 'rails_helper'

RSpec.describe Invoice, type: :model do
  let(:company) { Company.create!(name: "CompanyTest", siret: 321654, siren: 3216, vat_number: "FR6776578658765") }
  let(:valid_attributes) { { company: company,
                             status: "pending",
                             number: "AA-123456",
                             issue_date: Date.yesterday,
                             due_date: Date.yesterday + 1.month,
                             total_ht: 100.0,
                             vat_rate: 20.00,
                             currency: "EUR" } }
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

    it "is not valid without a VAT rate" do
      subject.vat_rate = nil
      expect(subject).not_to be_valid
    end

    it "is not valid without a TOTAL HT" do
      subject.total_ht = nil
      expect(subject).not_to be_valid
    end

    it "is not valid with a negative VAT rate" do
      subject.vat_rate = -5.0
      expect(subject).not_to be_valid
    end

    it "is not valid with a negative TOTAL HT" do
      subject.total_ht = -100.0
      expect(subject).not_to be_valid
    end
  end

  describe "callbacks" do
    describe "#calculate_total_ttc" do
      it "calculates the correct TTC amount before saving" do
        subject.save
        expect(subject.total_ttc).to eq(120)
      end
    end
  end
end
