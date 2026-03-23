# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
User.destroy_all
User.create!(email: "example@example.com", password: "1234567")

Company.destroy_all
10.times.each do |i|
  company = Company.find_or_create_by!(name: "Company #{i}")

  invoice_nb = rand(1..50)
  invoices_sample = Array.new(invoice_nb).map do |f|
    issue_date = Date.today - rand(0..100).days
    due_date = issue_date + 30.days
    vat_amount = 20.0
    total_ht = rand(100..50000) / 100.0
    total_ttc = total_ht * (1 + vat_amount / 100.0)
    {
      number: SecureRandom.uuid,
      issue_date: issue_date,
      due_date: due_date,
      total_ht: total_ht,
      total_ttc: total_ttc,
      vat_amount: vat_amount,
      currency: "EUR"
    }
  end

  company.invoices.create!(invoices_sample)
end

