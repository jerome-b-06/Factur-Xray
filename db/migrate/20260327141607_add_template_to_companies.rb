class AddTemplateToCompanies < ActiveRecord::Migration[8.1]
  def change
    add_column :companies, :invoice_template, :text
  end
end
