class RemoveUnusedFields < ActiveRecord::Migration[8.1]
  def change
    remove_column :invoices, :total_ht
    remove_column :invoices, :total_ttc
    remove_column :invoices, :vat_rate
    remove_column :invoices, :is_compliant
    remove_column :invoices, :audit_report
  end
end
