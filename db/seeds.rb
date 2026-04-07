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
  company = Company.find_or_create_by!(
    name: "Company #{i}",
    siret: "#{i}12345",
    siren: "#{i}6789098",
    vat_number: "FR-#{i}421356765432",
    invoice_template: '<h1>{{company_name}}</h1>
                       <small>VAT N° {{company_vat_number}}</small>
                       <h2 style="margin-top:10px;">Invoice N° {{number}}</h2>
                       <div style="margin-top:10px;">Issue date: {{issue_date}}</div>
                       <div>Please remit until: {{due_date}}</div>
                       <br><br>
                       {{list_of_invoiced_items}}
                       <div style="margin-top:10px;">Total HT: {{total_ht}}</div>
                       <div style="margin-top:10px;">VAT amount: {{total_vat}}</div>
                       <div style="margin-top:10px;">Total TTC: {{total_ttc}}</div>'
  )

  invoice_nb = rand(1..50)
  invoices_sample = Array.new(invoice_nb).map do |f|
    issue_date = Date.today - rand(0..100).days
    due_date = issue_date + 30.days
    {
      number: SecureRandom.uuid,
      status: 'draft',
      issue_date: issue_date,
      due_date: due_date,
      invoice_items_attributes: [
        { description: "Produit_1", quantity: 15, unit_price: 100.0, vat_rate: 20.0 },
        { description: "Produit_2", quantity: 3, unit_price: 10.0, vat_rate: 20.0 },
        { description: "Produit_3", quantity: 15.8, unit_price: 1000.0, vat_rate: 20.0 }
      ]
    }
  end

  company.invoices.create!(invoices_sample)
end
