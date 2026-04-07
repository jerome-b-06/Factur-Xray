require 'rails_helper'

RSpec.describe "Invoice Validations", type: :system do
  let!(:user) { User.create!(email: "comptable@business.fr", password: "password123") }
  let(:valid_pdf_path) { Rails.root.join('spec', 'fixtures', 'files', 'valid_facturx.pdf') }
  let(:invalid_pdf_path) { Rails.root.join('spec', 'fixtures', 'files', 'standard.pdf') }
  let(:corrupted_pdf_path) { Rails.root.join('spec', 'fixtures', 'files', 'corrupted_file.pdf') }

  before do
    sign_in user
    driven_by(:rack_test)
  end

  it "allows a user to upload and validate a compliant invoice" do
    visit new_invoice_validation_path

    # Check if the page loaded correctly
    expect(page).to have_content("Validate your Invoice!")

    # Upload the valid file
    attach_file "invoice_validation[file]", valid_pdf_path
    click_button "Extract & Validate"

    # Verify we are redirected to the show page with success UI
    expect(page).to have_content("Validation Report")
    expect(page).to have_content("Valid Factur-X Invoice")

    # Verify some DaisyUI components rendered data
    expect(page).to have_content("Seller Details")
    expect(page).to have_content("VAT Breakdown")
  end

  it "displays errors when uploading a standard PDF without XML" do
    visit new_invoice_validation_path

    attach_file "invoice_validation[file]", invalid_pdf_path
    click_button "Extract & Validate"

    # Verify failure UI
    expect(page).to have_content("Validation Failed")
    expect(page).to have_content("Issues Detected:")
    expect(page).to have_content("No Factur-X/ZUGFeRD XML attachment found")
  end

  it "displays errors when uploading a corrupted or unreadable PDF" do
    visit new_invoice_validation_path

    attach_file "invoice_validation[file]", corrupted_pdf_path
    click_button "Extract & Validate"

    # Verify failure UI
    expect(page).to have_content("Validation Failed")
    expect(page).to have_content("Issues Detected:")
    expect(page).to have_content("An error occurred while processing the file: PDF malformed")
  end

  it "shows validation errors if submitted completely empty" do
    visit new_invoice_validation_path

    # Submit without attaching a file
    click_button "Extract & Validate"

    # Should re-render the form with Active Record errors
    expect(page).to have_content("File can't be blank")
  end
end
