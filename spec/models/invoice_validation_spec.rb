require 'rails_helper'

RSpec.describe InvoiceValidation, type: :model do

  describe 'validations' do
    it 'is invalid without a file attached' do
      validation = InvoiceValidation.new
      expect(validation).not_to be_valid
      expect(validation.errors[:file]).to include(I18n.t('errors.messages.blank'))
    end

    it 'is valid with a file attached' do
      validation = InvoiceValidation.new
      validation.file.attach(
        io: StringIO.new('fake pdf content'),
        filename: 'test.pdf',
        content_type: 'application/pdf'
      )
      expect(validation).to be_valid
    end
  end

  describe '#valid_invoice?' do
    it 'returns true if the status is valid' do
      validation = InvoiceValidation.new(status: 'valid')
      expect(validation.valid_invoice?).to be true
    end

    it 'returns false if the status is invalid or nil' do
      expect(InvoiceValidation.new(status: 'invalid').valid_invoice?).to be false
      expect(InvoiceValidation.new(status: nil).valid_invoice?).to be false
    end
  end

end
