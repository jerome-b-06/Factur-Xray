require 'rails_helper'

RSpec.describe "Invoices", type: :system do
  let!(:user) { User.create!(email: "comptable@business.fr", password: "password123") }
  let!(:company) { Company.create!(name: "CompanyTest", siret: "123456789", siren: "987654", vat_number: "FR0123456") }

  before do
    sign_in user
    driven_by(:rack_test)
  end

  describe "Listing invoices" do
    it "displays the invoice list on the company show page" do
      company.invoices.create!([
                                 { number: "INVOICE-1", total_ht: 100, vat_rate: 20, issue_date: Date.today, due_date: Date.tomorrow },
                                 { number: "INVOICE-2", total_ht: 300, vat_rate: 20, issue_date: Date.today, due_date: Date.tomorrow }
                               ])

      visit company_path(company)

      expect(page).to have_content("CompanyTest")
      expect(page).to have_content("123456789")
      expect(page).to have_content("FR0123456")
      expect(page).to have_content("INVOICE-1")
      expect(page).to have_content("")
      expect(page).to have_content("120,00 €")
      expect(page).to have_content("480,00 €") # TotalTTC of all invoices
    end
  end

  describe "Creating an invoice" do
    it "allows a user to create an invoice with calculated TTC" do
      visit company_path(company)
      click_on "+ New Invoice"

      fill_in "Number", with: "INV-001"
      fill_in "Issue date", with: Date.today
      fill_in "Due date", with: Date.tomorrow + 1.month
      fill_in "Total ht", with: 1000.00
      fill_in "Vat rate", with: 20.00
      fill_in "Currency", with: "EUR"

      click_on "Save"

      expect(page).to have_content("INV-001")
    end
  end

  describe "Editing an invoice" do
    let!(:invoice) { company.invoices.create!(number: "INV-OLD", total_ht: 100, vat_rate: 20, issue_date: Date.today, due_date: Date.tomorrow) }

    it "updates the TTC when HT amount is changed" do
      visit company_path(company)
      within("#invoice_#{invoice.id}") do
        click_on "Éditer"
      end

      fill_in "Total ht", with: 200.00
      click_on "Save"

      expect(page).to have_content("200,00 €")
      expect(page).to have_content("240,00 €")
    end
  end

  describe "Deleting an invoice" do
    # Need of Selenium for Turbo Confirm (JS)
    it "removes the invoice from the list", js: true do
      driven_by(:selenium_chrome_headless)

      company.invoices.create!(number: "TO-DELETE", total_ht: 100.00, vat_rate: 20, issue_date: Date.today, due_date: Date.tomorrow)
      visit company_path(company)
      click_on "Voir"

      accept_confirm do
        click_on "Destroy this invoice"
      end

      expect(page).not_to have_content("TO-DELETE")
    end
  end
end
