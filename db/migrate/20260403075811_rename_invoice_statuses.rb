class RenameInvoiceStatuses < ActiveRecord::Migration[8.1]
  def change
    rename_enum_value :status_option, from: "pending", to: "draft"
    rename_enum_value :status_option, from: "processed", to: "sent"
    rename_enum_value :status_option, from: "error", to: "paid"

    change_column_default :invoices, :status, from: "pending", to: "draft"
  end
end
