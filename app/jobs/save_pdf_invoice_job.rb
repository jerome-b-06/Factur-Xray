class SavePdfInvoiceJob < ApplicationJob
  queue_as :default

  def perform(invoice)
    @invoice = invoice
    @company = invoice.company
    pdf_data = PdfGenerator.new(html_to_print).generate

    xml_data = XmlInvoiceGenerator.new(@invoice).generate

    doc = HexaPDF::Document.new(io: StringIO.new(pdf_data))

    # ajout du fichier XML à l'intérieur du document PDF
    # Le nom "factur-x.xml" est standardisé et attendu par les logiciels comptables
    doc.files.add(
      StringIO.new(xml_data),
      name: 'factur-x.xml',
      description: 'Factur-X XML Invoice'
    )

    final_pdf_io = StringIO.new
    doc.write(final_pdf_io)
    final_pdf_data = final_pdf_io.string

    @invoice.skip_pdf_generation = true

    @invoice.pdf_invoice.attach(
      io: StringIO.new(final_pdf_data),
      filename: "facture_#{@invoice.number}.pdf",
      content_type: "application/pdf"
    )
  end

  private

  def html_to_print
    ActionController::Base.render(
      inline: "<%= content %>",
      layout: "layouts/pdf",
      locals: { content: content }
    )
  end

  def content
    raw_content = @company.invoice_template.to_s
    regex = /\{\{(\w+)\}\}/

    final_content = raw_content.gsub(regex) do |match|
      field_name = $1

      if field_name === 'list_of_invoiced_items'
        "<table style='width: 100%; border-collapse: collapse;'>" +
          "<thead>" +
          "<tr>" +
          "<th style='border: 1px solid #000; padding: 8px;'>Description</th>" +
          "<th style='border: 1px solid #000; padding: 8px;'>Quantity</th>" +
          "<th style='border: 1px solid #000; padding: 8px;'>Unit price</th>" +
          "<th style='border: 1px solid #000; padding: 8px;'>Total HT</th>" +
          "<th style='border: 1px solid #000; padding: 8px;'>VAT</th>" +
          "<th style='border: 1px solid #000; padding: 8px;'>Total TTC</th>" +
          "</tr>" +
          "</thead>" +
          "<tbody>" +
          @invoice.invoice_items.map do |item|
            "<tr>" +
              "<td style='border: 1px solid #000; padding: 8px;'>#{item.description}</td>" +
              "<td style='border: 1px solid #000; padding: 8px; text-align: right;'>#{item.quantity}</td>" +
              "<td style='border: 1px solid #000; padding: 8px; text-align: right;'>#{format_value(item.unit_price)}</td>" +
              "<td style='border: 1px solid #000; padding: 8px; text-align: right;'>#{format_value(item.total_ht)}</td>" +
              "<td style='border: 1px solid #000; padding: 8px; text-align: right;'>#{format_value(item.vat_rate)}</td>" +
              "<td style='border: 1px solid #000; padding: 8px; text-align: right;'>#{format_value(item.total_ttc)}</td>" +
              "</tr>"
          end.join +
          "</tbody>" +
          "</table>"
      elsif @invoice.respond_to?(field_name)
        value = @invoice.public_send(field_name)
        format_value(value)
      else
        "Unknown field (#{field_name})"
      end
    end

    final_content.html_safe
  end

  def format_value(value)
    case value
    when Date, Time, ActiveSupport::TimeWithZone
      value.strftime("%d/%m/%Y")
    when BigDecimal, Float
      ActionController::Base.helpers.number_to_currency(value, format: "%n %u", unit: "€")
    else
      value.to_s
    end
  end

end
