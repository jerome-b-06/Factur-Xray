class CreateInvoices < ActiveRecord::Migration[8.1]
  def change
    create_enum :status_option, %w[pending processed error]

    create_table :invoices do |t|
      t.references :company, null: false, foreign_key: true
      t.enum :status, enum_type: "status_option", default: "pending"
      t.string :number
      t.date :issue_date
      t.date :due_date
      t.decimal :total_ht, precision: 15, scale: 2, default: 0.0, null: false
      t.decimal :total_ttc, precision: 15, scale: 2, default: 0.0, null: false
      t.decimal :vat_rate, precision: 5, scale: 2, default: 0.0, null: false
      t.string :currency
      t.boolean :is_compliant
      t.jsonb :audit_report
      t.timestamps
    end

    add_index :invoices, :status
    add_index :invoices, :audit_report, using: :gin
  end
end
