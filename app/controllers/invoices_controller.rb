class InvoicesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company
  before_action :set_invoice, only: %i[ show edit update destroy download ]

  # GET /invoices/1 or /invoices/1.json
  def show
  end

  # GET /invoices/new
  def new
    @invoice = Invoice.new
  end

  # GET /invoices/1/edit
  def edit
    redirect_to company_invoice_path(@company, @invoice) unless @invoice.editable?
  end

  # POST /invoices or /invoices.json
  def create
    @invoice = @company.invoices.new(invoice_params)

    if @invoice.save
      redirect_to company_path(@company), notice: "Invoice was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /invoices/1 or /invoices/1.json
  def update
    if @invoice.update(invoice_params)
      redirect_to company_path(@company), notice: "Invoice was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /invoices/1 or /invoices/1.json
  def destroy
    @invoice.destroy!
    redirect_to company_path(@company), notice: "Invoice was successfully destroyed.", status: :see_other
  end

  def add_item
    @invoice = params[:id] ? Invoice.find(params[:id]) : Invoice.new(invoice_params)
    @invoice.invoice_items.build

    render :edit, status: :unprocessable_entity if params[:id]
    render :new, status: :unprocessable_entity unless params[:id]
  end

  def download
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_company
    @company = Company.find(params[:company_id])
  end

  def set_invoice
    @invoice = @company.invoices.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def invoice_params
    params.require(:invoice).permit(
      :number, :issue_date, :due_date, :status,
      invoice_items_attributes: [
        :id, :description, :quantity, :unit_price, :vat_rate, :_destroy
      ]
    )
  end
end
