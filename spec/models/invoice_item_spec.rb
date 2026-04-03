require 'rails_helper'

RSpec.describe InvoiceItem, type: :model do
  let(:company) { Company.create!(name: "Test Company", siret: 123456, siren: 123, vat_number: "FR123456789") }
  let(:invoice) { Invoice.create!(company: company, status: "draft", number: "AA-123", issue_date: Date.today, due_date: Date.today + 1.month) }
  subject { described_class.new(invoice: invoice, description: "Test Item", quantity: 2, unit_price: 50.0, vat_rate: 10.0) }

  describe "associations" do
    it "belongs to an invoice" do
      expect(subject.invoice).to eq(invoice)
    end
  end

  describe "validations" do
    it "is valid with valid attributes" do
      expect(subject).to be_valid
    end

    it "is invalid without a description" do
      subject.description = nil
      expect(subject).not_to be_valid
    end

    it "is invalid without a quantity" do
      subject.quantity = nil
      expect(subject).not_to be_valid
    end

    it "is invalid without a unit_price" do
      subject.unit_price = nil
      expect(subject).not_to be_valid
    end

    it "is invalid without a vat_rate" do
      subject.vat_rate = nil
      expect(subject).not_to be_valid
    end
  end

  describe "calculations" do
    it "calculates total_ht as quantity multiplied by unit_price" do
      subject.save
      expect(subject.total_ht).to eq(100.0)
    end

    it "calculates total_vat as total_ht multiplied by vat_rate percentage" do
      subject.save
      expect(subject.total_vat).to eq(10.0)
    end

    it "calculates total_ttc as total_ht plus total_vat" do
      subject.save
      expect(subject.total_ttc).to eq(110.0)
    end

    it "calculates totals correctly with zero quantity" do
      subject.quantity = 0
      subject.save
      expect(subject.total_ht).to eq(0.0)
      expect(subject.total_vat).to eq(0.0)
      expect(subject.total_ttc).to eq(0.0)
    end

    it "calculates totals correctly with zero unit_price" do
      subject.unit_price = 0
      subject.save
      expect(subject.total_ht).to eq(0.0)
      expect(subject.total_vat).to eq(0.0)
      expect(subject.total_ttc).to eq(0.0)
    end

    it "calculates totals correctly with zero vat_rate" do
      subject.vat_rate = 0
      subject.save
      expect(subject.total_ht).to eq(100.0)
      expect(subject.total_vat).to eq(0.0)
      expect(subject.total_ttc).to eq(100.0)
    end

    it "calculates totals correctly with decimal values" do
      subject.quantity = 1.5
      subject.unit_price = 33.33
      subject.vat_rate = 5.5
      subject.save
      expect(subject.total_ht).to eq(50.0)
      expect(subject.total_vat).to eq(2.75)
      expect(subject.total_ttc).to eq(52.75)
    end
  end
end
