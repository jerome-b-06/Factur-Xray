require 'rails_helper'

RSpec.describe "Companies", type: :system do
  let!(:user) { User.create!(email: "comptable@business.fr", password: "password123") }
  let!(:company) { Company.create!(name: "CompanyTest", siret: "123456789", siren: "987654", vat_number: "FR0123456") }

  before do
    sign_in user
    driven_by(:rack_test)
  end

  describe "Listing companies" do
    it "displays the companies list" do
      visit companies_path

      expect(page).to have_content("CompanyTest")
      expect(page).to have_content("123456789")
    end
  end

  describe "Creating a company" do
    it "allows a user to create a company" do
      visit companies_path
      click_on "New company"

      fill_in "Name", with: "COMPANY1"
      fill_in "Siret", with: 159753
      fill_in "Siren", with: 987654
      fill_in "Vat number", with: "FR-987654321"

      click_on "Save"

      expect(page).to have_content("COMPANY1")
      expect(page).to have_content(159753)
      expect(page).to have_content("FR-987654321")
    end
  end

  describe "Editing a company" do
    it "allows a user to update a company" do
      visit companies_path
      within("#company_#{company.id}") do
        click_on "Edit"
      end

      fill_in "Name", with: "COMPANY1"
      fill_in "Siret", with: 159753
      fill_in "Siren", with: 987654
      fill_in "Vat number", with: "FR-987654321"

      click_on "Save"

      expect(page).to have_content("COMPANY1")
    end
  end

  describe "Deleting an invoice" do
    # Need of Selenium for Turbo Confirm (JS)
    it "removes the invoice from the list", js: true do
      driven_by(:selenium_chrome_headless)

      visit companies_path

      accept_confirm do
        within("#company_#{company.id}") do
          click_on "Supprimer"
        end
      end

      expect(page).not_to have_content("CompanyTest")
    end
  end
end
