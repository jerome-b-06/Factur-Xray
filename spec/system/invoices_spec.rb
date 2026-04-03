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
                                 { number: "INVOICE-1",
                                   issue_date: Date.today,
                                   due_date: Date.tomorrow,
                                   invoice_items_attributes: [
                                     { description: "Produit_1", quantity: 1, unit_price: 100.0, vat_rate: 20.0 },
                                     { description: "Produit_2", quantity: 10, unit_price: 10.0, vat_rate: 20.0 }
                                   ]
                                 },
                                 { number: "INVOICE-2",
                                   issue_date: Date.today,
                                   due_date: Date.tomorrow,
                                   invoice_items_attributes: [
                                     { description: "Produit_1", quantity: 1, unit_price: 100.0, vat_rate: 20.0 },
                                     { description: "Produit_2", quantity: 10, unit_price: 10.0, vat_rate: 20.0 }
                                   ]
                                 }
                               ])

      visit company_path(company)

      expect(page).to have_content("CompanyTest")
      expect(page).to have_content("123456789")
      expect(page).to have_content("FR0123456")
      expect(page).to have_content("INVOICE-1")
      expect(page).to have_content("")
      expect(page).to have_content("240,00 €") # TotalTTC of one invoice
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

      click_on "Save"

      expect(page).to have_content("INV-001")
    end
  end

  describe "Editing an invoice" do
    let!(:invoice) { company.invoices.create!(
      number: "INV-OLD",
      issue_date: Date.today,
      due_date: Date.tomorrow,
      invoice_items_attributes: [
        { description: "Produit_1", quantity: 1, unit_price: 10.0, vat_rate: 20.0 }
      ]
    ) }

    it "updates the TTC when HT amount is changed" do
      visit company_path(company)
      within("#invoice_#{invoice.id}") do
        click_on "Edit"
      end

      fill_in "invoice[invoice_items_attributes][0][unit_price]", with: 200.00
      click_on "Save"

      expect(page).to have_content("200,00 €")
      expect(page).to have_content("240,00 €")
    end

    it "updates the TTC when VAT rate is changed" do
      visit company_path(company)
      within("#invoice_#{invoice.id}") do
        click_on "Edit"
      end

      fill_in "invoice[invoice_items_attributes][0][vat_rate]", with: 5.50
      click_on "Save"

      expect(page).to have_content("10,55 €")
    end

    it "updates the TTC when Quantity is changed" do
      visit company_path(company)
      within("#invoice_#{invoice.id}") do
        click_on "Edit"
      end

      fill_in "invoice[invoice_items_attributes][0][quantity]", with: 10
      click_on "Save"

      expect(page).to have_content("100,00 €")
      expect(page).to have_content("120,00 €")
    end

    it "updates amounts when a new item is added " do
      driven_by(:selenium_chrome_headless)

      visit company_path(company)
      within("#invoice_#{invoice.id}") do
        click_on "Edit"
      end

      click_on "Add a new item"

      fill_in "invoice[invoice_items_attributes][1][description]", with: "Produit_2"
      fill_in "invoice[invoice_items_attributes][1][quantity]", with: 5
      fill_in "invoice[invoice_items_attributes][1][unit_price]", with: 50.00
      fill_in "invoice[invoice_items_attributes][1][vat_rate]", with: 20.0

      click_on "Save"

      expect(page).to have_content("260,00 €")
      expect(page).to have_content("312,00 €")
    end

    it "updates amounts when a new item is deleted " do
      visit company_path(company)
      within("#invoice_#{invoice.id}") do
        click_on "Edit"
      end
      within("#invoice_items") do |items|
        items.check('invoice[invoice_items_attributes][0][_destroy]')
      end

      click_on "Save"

      expect(page).to have_content("0,00 €")
      expect(page).to have_content("0,00 €")
    end
  end

  describe "Deleting an invoice" do
    # Need of Selenium for Turbo Confirm (JS)
    it "removes the invoice from the list", js: true do
      driven_by(:selenium_chrome_headless)

      company.invoices.create!(number: "TO-DELETE",
                               issue_date: Date.today,
                               due_date: Date.tomorrow,
                               invoice_items_attributes: [
                                 { description: "Produit_1", quantity: 1, unit_price: 100.0, vat_rate: 20.0 },
                                 { description: "Produit_2", quantity: 10, unit_price: 10.0, vat_rate: 20.0 }
                               ])
      visit company_path(company)
      click_on "Show"

      accept_confirm do
        click_on "Destroy this invoice"
      end

      expect(page).not_to have_content("TO-DELETE")
    end
  end
end
