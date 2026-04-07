require 'rails_helper'

RSpec.describe InvoiceValidatorService do
  let(:invoice_validation) { InvoiceValidation.new }

  # Helper method to attach a fixture file to our record
  def attach_fixture(filename)
    file_path = Rails.root.join('spec', 'fixtures', 'files', filename)
    invoice_validation.file.attach(io: File.open(file_path), filename: filename, content_type: 'application/pdf')
  end

  describe '#process!' do
    context 'when the PDF contains a valid Factur-X XML' do
      before do
        attach_fixture('valid_facturx.pdf')
        invoice_validation.save!
        described_class.new(invoice_validation).process!
        invoice_validation.reload
      end

      it 'sets the status to valid' do
        expect(invoice_validation.status).to eq('valid')
        expect(invoice_validation.error_messages).to be_empty
      end

      it 'extracts the basic invoice data' do
        expect(invoice_validation.vendor_name).to be_present
        expect(invoice_validation.invoice_number).to be_present
      end

      it 'populates the extracted_data JSON hash' do
        expect(invoice_validation.extracted_data).to be_a(Hash)
        expect(invoice_validation.extracted_data['seller']['name']).to be_present
        expect(invoice_validation.extracted_data['totals']['total_ttc']).to be_present
      end
    end

    context 'when the PDF does not contain an XML attachment' do
      before do
        attach_fixture('standard.pdf')
        invoice_validation.save!
        described_class.new(invoice_validation).process!
        invoice_validation.reload
      end

      it 'sets the status to invalid' do
        expect(invoice_validation.status).to eq('invalid')
      end

      it 'adds an error message about the missing attachment' do
        expect(invoice_validation.error_messages).to include(/No Factur-X\/ZUGFeRD XML attachment found/i)
      end
    end

    context 'when handling corrupted or unreadable files' do
      before do
        attach_fixture('corrupted_file.pdf')
        invoice_validation.save!
        described_class.new(invoice_validation).process!
        invoice_validation.reload
      end

      it 'rescues the error gracefully and marks as invalid' do
        expect(invoice_validation.status).to eq('invalid')
        expect(invoice_validation.error_messages.first).to match(/An error occurred while processing/)
      end
    end
  end
end
