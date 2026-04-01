# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PdfGenerator, type: :service do
  describe ".html_to_pdf" do
    let(:html_input) { "<html><body><h1>Facture PDF</h1><p>Montant: 120,00 €</p></body></html>" }

    subject(:pdf_data) { PdfGenerator.new(html_input).generate }

    it "content is non empty string" do
      expect(pdf_data).to be_present
      expect(pdf_data).to be_a(String)
    end

    it "content begins with %PDF" do
      expect(pdf_data[0..3]).to eq("%PDF")
    end

    it "PDF text content is th one we are waiting for" do
      io = StringIO.new(pdf_data)
      reader = PDF::Reader.new(io)

      page_text = reader.pages.first.text

      expect(page_text).to include("Facture PDF")
      expect(page_text).to include("120,00 €")
    end
  end
end
