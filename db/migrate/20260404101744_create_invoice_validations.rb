class CreateInvoiceValidations < ActiveRecord::Migration[8.1]
  def change
    create_table :invoice_validations do |t|
      t.string :status
      t.string :vendor_name
      t.string :invoice_number
      t.jsonb :extracted_data, default: {}, null: false
      t.string :error_messages, array: true, default: []
      t.timestamps
    end

    add_index :invoice_validations, :extracted_data, using: :gin
  end
end
