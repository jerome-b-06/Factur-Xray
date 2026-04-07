class CompaniesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company, only: %i[ show edit update destroy ]

  # GET /companies or /companies.json
  def index
    @companies = Company.all
  end

  # GET /companies/1 or /companies/1.json
  def show
    @invoices = @company.invoices.with_attached_pdf_invoice.includes(:invoice_items).order(created_at: :desc)
  end

  # GET /companies/new
  def new
    @company = Company.new
  end

  # GET /companies/1/edit
  def edit
  end

  # POST /companies or /companies.json
  def create
    @company = Company.new(company_params)

    if @company.save
      redirect_to @company, notice: "Company was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /companies/1 or /companies/1.json
  def update
    if @company.update(company_params)
      redirect_to @company, notice: "Company was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /companies/1 or /companies/1.json
  def destroy
    @company.destroy!
    redirect_to companies_path, notice: "Company was successfully destroyed.", status: :see_other
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_company
    @company = Company.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def company_params
    params.expect(company: [ :name, :siret, :siren, :vat_number, :invoice_template ])
  end
end
