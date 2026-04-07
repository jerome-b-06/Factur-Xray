require "hexapdf"
require "nokogiri"

class InvoiceValidatorService
  def initialize(invoice_validation)
    @validation = invoice_validation
    @errors = []
  end

  def process!
    begin
      pdf_data = @validation.file.download
      doc = HexaPDF::Document.new(io: StringIO.new(pdf_data))

      # 1. On cherche dans doc.files un fichier dont le nom contient "factur-x.xml" ou "zugferd"
      matched_file = doc.files.find do |filespec|
        name = filespec.path().downcase
        name.include?("factur-x.xml") || name.include?("zugferd")
      end

      if matched_file.nil?
        @errors << "No Factur-X/ZUGFeRD XML attachment found in the PDF."
        fail_validation!
        return
      end

      xml_content = matched_file.embedded_file_stream.stream

      xml_doc = Nokogiri::XML(xml_content)
      xml_doc.remove_namespaces!

      extract_data(xml_doc)
      validate_rules!

    rescue StandardError => e
      @errors << "An error occurred while processing the file: #{e.message}"
    ensure
      finalize_validation!
    end
  end

  private

  def extract_data(xml_doc)
    # Données de base
    @validation.vendor_name = xml_doc.at_css("SellerTradeParty Name")&.text
    @validation.invoice_number = xml_doc.at_css("ExchangedDocument ID")&.text

    # Structure JSON enrichie
    @validation.extracted_data = {
      seller: extract_party(xml_doc, "SellerTradeParty"),
      buyer: extract_party(xml_doc, "BuyerTradeParty"),
      totals: extract_totals(xml_doc),
      vat_breakdown: extract_vat_breakdown(xml_doc),
      line_items: extract_line_items(xml_doc)
    }
  end

  def extract_party(xml_doc, tag_name)
    node = xml_doc.at_css(tag_name)
    return {} unless node

    {
      name: node.at_css("Name")&.text,
      siret: node.at_css("ID[schemeID='0002']")&.text,
      vat_number: node.at_css("SpecifiedTaxRegistration ID[schemeID='VA']")&.text,
      address: node.at_css("PostalTradeAddress LineOne")&.text,
      zip: node.at_css("PostalTradeAddress PostcodeCode")&.text,
      city: node.at_css("PostalTradeAddress CityName")&.text,
      country: node.at_css("PostalTradeAddress CountryID")&.text
    }
  end

  def extract_totals(xml_doc)
    node = xml_doc.at_css("SpecifiedTradeSettlementHeaderMonetarySummation")
    return {} unless node

    {
      total_ht: node.at_css("TaxBasisTotalAmount")&.text&.to_f,
      total_vat: node.at_css("TaxTotalAmount")&.text&.to_f,
      total_ttc: node.at_css("GrandTotalAmount")&.text&.to_f,
      due_amount: node.at_css("DuePayableAmount")&.text&.to_f
    }
  end

  def extract_vat_breakdown(xml_doc)
    # On cherche les blocs ApplicableTradeTax au niveau global (Header)
    nodes = xml_doc.css("ApplicableHeaderTradeSettlement > ApplicableTradeTax")
    nodes.map do |node|
      {
        rate: node.at_css("RateApplicablePercent")&.text&.to_f,
        basis_amount: node.at_css("BasisAmount")&.text&.to_f,
        calculated_amount: node.at_css("CalculatedAmount")&.text&.to_f,
        category: node.at_css("CategoryCode")&.text
      }
    end
  end

  def extract_line_items(xml_doc)
    nodes = xml_doc.css("IncludedSupplyChainTradeLineItem")
    nodes.map do |node|
      {
        line_id: node.at_css("AssociatedDocumentLineDocument LineID")&.text,
        description: node.at_css("SpecifiedTradeProduct Name")&.text,
        quantity: node.at_css("BilledQuantity")&.text&.to_f,
        unit_price: node.at_css("NetPriceProductTradePrice ChargeAmount")&.text&.to_f,
        vat_rate: node.at_css("ApplicableTradeTax RateApplicablePercent")&.text&.to_f,
        line_total: node.at_css("SpecifiedTradeSettlementLineMonetarySummation LineTotalAmount")&.text&.to_f
      }
    end
  end

  def validate_rules!
    @errors << "Vendor name is missing." if @validation.vendor_name.blank?
    @errors << "Buyer name is missing." if @validation.extracted_data.dig("buyer", "name").blank?
    @errors << "Invoice number is missing." if @validation.invoice_number.blank?
    @errors << "BuyTotal amount is missing or zero." if @validation.extracted_data.dig("totals", "due_amount").blank?
  end

  def fail_validation!
    @validation.status = "invalid"
    @validation.error_messages = @errors
    @validation.save!
  end

  def finalize_validation!
    @validation.status = @errors.empty? ? "valid" : "invalid"
    @validation.error_messages = @errors
    @validation.save!
  end
end
