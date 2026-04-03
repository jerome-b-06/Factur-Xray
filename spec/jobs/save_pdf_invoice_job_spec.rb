require 'rails_helper'

RSpec.describe SavePdfInvoiceJob, type: :job do
  let(:company) { Company.create!(name: "Company1",
                                  siret: 9876,
                                  siren: 987654321,
                                  vat_number: "FR0123456",
                                  invoice_template: "<h1>Invoice n° {{number}}</h1>
                                                     <div>{{other_field}}</div>"
  ) }
  let(:invoice) { Invoice.create!(company: company,
                                  number: "INV-2026",
                                  issue_date: Date.new(2026, 1, 1),
                                  due_date: Date.new(2026, 3, 1),
                                  invoice_items_attributes: [
                                    { description: "Produit_1", quantity: 1, unit_price: 100.0, vat_rate: 20.0 },
                                    { description: "Produit_2", quantity: 10, unit_price: 10.0, vat_rate: 20.0 }
                                  ]
  ) }

  describe "#perform" do

    it "Attach pdf file to invoice" do
      expect {
        described_class.perform_now(invoice)
      }.to change { invoice.pdf_invoice.attached? }.from(false).to(true)
    end

    it "PDF file has a correct filename" do
      described_class.perform_now(invoice)
      expect(invoice.pdf_invoice.filename.to_s).to eq("facture_INV-2026.pdf")
      expect(invoice.pdf_invoice.content_type).to eq("application/pdf")
    end

    it "Known fields are correctly replaced by values, other by 'Unknown field'" do
      described_class.perform_now(invoice)

      pdf_content = invoice.pdf_invoice.download
      reader = PDF::Reader.new(StringIO.new(pdf_content))
      page_text = reader.pages.first.text

      expect(page_text).to include("Invoice n° INV-2026")
      expect(page_text).to include("Unknown field (other_field)")
    end
  end

end
