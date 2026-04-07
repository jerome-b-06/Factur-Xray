class InvoiceValidationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_invoice_validation, only: %i[ show destroy ]

  def index
    @invoice_validations = InvoiceValidation.all.order(created_at: :desc)
  end

  def new
    @invoice_validation = InvoiceValidation.new
  end

  def create
    @invoice_validation = InvoiceValidation.new(invoice_validation_params)

    if @invoice_validation.save
      # Process the PDF immediately
      InvoiceValidatorService.new(@invoice_validation).process!

      redirect_to @invoice_validation
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  # DELETE /invoices/1
  def destroy
    @invoice_validation.destroy!
    redirect_to invoice_validations_path, notice: "Invoice validation was successfully destroyed.", status: :see_other
  end

  private

  def set_invoice_validation
    @invoice_validation = InvoiceValidation.find(params[:id])
  end

  def invoice_validation_params
    params.require(:invoice_validation).permit(:file)
  end
end
