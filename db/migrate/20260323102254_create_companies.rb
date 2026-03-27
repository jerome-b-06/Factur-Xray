class CreateCompanies < ActiveRecord::Migration[8.1]
  def change
    create_table :companies do |t|
      t.string :name
      t.bigint :siret
      t.bigint :siren
      t.string :vat_number

      t.timestamps
    end
  end
end
