require 'rails_helper'

RSpec.describe Company, type: :model do
  let(:valid_invoice_1_attributes) {
    { status: "draft",
      number: "AA-123456",
      issue_date: Date.yesterday,
      due_date: Date.yesterday + 1.month
    }
  }
  let(:valid_invoice_2_attributes) {
    { status: "draft",
      number: "AA-12345678",
      issue_date: Date.yesterday,
      due_date: Date.yesterday + 1.month
    }
  }
  let(:valid_attributes) {
    { name: "CompanyTest", siret: 123456, siren: 123, vat_number: "FR123456789" }
  }

  subject {
    described_class.create!(valid_attributes)
  }

  describe "associations" do
    it "can have multiple invoices" do
      invoice1 = subject.invoices.create!(valid_invoice_1_attributes)
      invoice2 = subject.invoices.create!(valid_invoice_2_attributes)

      expect(subject.reload.invoices).to include(invoice1, invoice2)
    end

    it "destroys associated invoices when the company is deleted" do
      subject.invoices.create!(valid_invoice_1_attributes)

      expect { subject.destroy }.to change(Invoice, :count).by(-1)
    end
  end

  describe "validations" do
    it "is valid with valid attributes" do
      expect(subject).to be_valid
    end

    it "is not valid without a name" do
      subject.name = nil
      expect(subject).not_to be_valid
    end

    it "is not valid without a siret" do
      subject.siret = nil
      expect(subject).not_to be_valid
    end
    it "is not valid without a siren" do
      subject.siren = nil
      expect(subject).not_to be_valid
    end

    it "is not valid without a VAT Number" do
      subject.vat_number = nil
      expect(subject).not_to be_valid
    end

  end
end
