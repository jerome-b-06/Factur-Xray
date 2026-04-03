# frozen_string_literal: true

require 'builder'
class XmlInvoiceGenerator

  def initialize(invoice)
    @invoice = invoice
  end

  def generate
    xml = Builder::XmlMarkup.new(indent: 2)
    xml.instruct! :xml, version: "1.0", encoding: "UTF-8"

    # Les espaces de noms (namespaces) obligatoires pour la norme Factur-X
    xml.tag!("rsm:CrossIndustryInvoice",
             "xmlns:rsm" => "urn:un:unece:uncefact:data:standard:CrossIndustryInvoice:100",
             "xmlns:ram" => "urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100",
             "xmlns:udt" => "urn:un:unece:uncefact:data:standard:UnqualifiedDataType:100"
    ) do

      # ---------------------------------------------------------
      # 1. ENTÊTE DU DOCUMENT (ExchangedDocument)
      # ---------------------------------------------------------
      xml.tag!("rsm:ExchangedDocument") do
        xml.tag!("ram:ID", @invoice.number)
        xml.tag!("ram:TypeCode", "380") # 380 = Facture commerciale standard

        # Date d'émission (format 102 = YYYYMMDD)
        xml.tag!("ram:IssueDateTime") do
          xml.tag!("udt:DateTimeString", @invoice.issue_date.strftime("%Y%m%d"), format: "102")
        end
      end

      # ---------------------------------------------------------
      # 2. DONNÉES DE LA TRANSACTION (SupplyChainTradeTransaction)
      # ---------------------------------------------------------
      xml.tag!("rsm:SupplyChainTradeTransaction") do

        # Vendeur et Acheteur
        xml.tag!("ram:ApplicableHeaderTradeAgreement") do
          xml.tag!("ram:SellerTradeParty") do
            xml.tag!("ram:Name", @invoice.company.name)
            xml.tag!("ram:ID", @invoice.company.siret, schemeID: "0002") # 0002 = Code pour le SIRET
            # L'adresse de la société
            # xml.tag!("ram:PostalTradeAddress") do
            # xml.tag!("ram:PostcodeCode", @invoice.company.zip_code)
            # xml.tag!("ram:LineOne", @invoice.company.address)
            # xml.tag!("ram:CityName", @invoice.company.city)
            # xml.tag!("ram:CountryID", "FR")
            # end
            # TVA INTRACOMMUNAUTAIRE
            xml.tag!("ram:SpecifiedTaxRegistration") do
              xml.tag!("ram:ID", @invoice.company.vat_number, schemeID: "VA") # VA = Value Added Tax
            end
          end
        end

        xml.tag!("ram:BuyerTradeParty") do
          # Identifiant client (SIRET si disponible...)
          # xml.tag!("ram:ID", invoice.client.siret, schemeID: "0002") if invoice.client.siret.present?
          xml.tag!("ram:Name", "Customer Name")

          # L'adresse du client
          xml.tag!("ram:PostalTradeAddress") do
            xml.tag!("ram:PostcodeCode", "75000")
            xml.tag!("ram:LineOne", "Rue de Paris")
            xml.tag!("ram:CityName", "Paris")
            xml.tag!("ram:CountryID", "FR")
          end

          # TVA Intra  CLIENT, si applicable... if invoice.client.vat_number.present?
          # xml.tag!("ram:SpecifiedTaxRegistration") do
          #   xml.tag!("ram:ID", "FR1234567890", schemeID: "VA")
          # end
          # end
        end
      end

      # -- LIGNES DE FACTURE (IncludedSupplyChainTradeLineItem) --
      @invoice.invoice_items.each_with_index do |item, index|
        xml.tag!("ram:IncludedSupplyChainTradeLineItem") do

          # ID de la ligne (1, 2, 3...)
          xml.tag!("ram:AssociatedDocumentLineDocument") do
            xml.tag!("ram:LineID", index + 1)
          end

          # Description du produit
          xml.tag!("ram:SpecifiedTradeProduct") do
            xml.tag!("ram:Name", item.description)
          end

          # Prix unitaire HT
          xml.tag!("ram:SpecifiedLineTradeAgreement") do
            xml.tag!("ram:NetPriceProductTradePrice") do
              xml.tag!("ram:ChargeAmount", format('%.2f', item.unit_price))
            end
          end

          # Quantité (C62 = Unité standard internationale)
          xml.tag!("ram:SpecifiedLineTradeDelivery") do
            xml.tag!("ram:BilledQuantity", item.quantity.to_s, unitCode: "C62")
          end

          # TVA et Total HT de la ligne
          xml.tag!("ram:SpecifiedLineTradeSettlement") do
            xml.tag!("ram:ApplicableTradeTax") do
              xml.tag!("ram:TypeCode", "VAT")
              xml.tag!("ram:CategoryCode", "S") # S = Standard rate
              xml.tag!("ram:RateApplicablePercent", format('%.2f', item.vat_rate))
            end
            xml.tag!("ram:SpecifiedTradeSettlementLineMonetarySummation") do
              xml.tag!("ram:LineTotalAmount", format('%.2f', item.total_ht))
            end
          end
        end
      end

      # TOTAUX ET PAIEMENT (ApplicableHeaderTradeSettlement)
      xml.tag!("ram:ApplicableHeaderTradeSettlement") do
        xml.tag!("ram:InvoiceCurrencyCode", "EUR")

        # Date d'échéance (Due Date)
        xml.tag!("ram:SpecifiedTradePaymentTerms") do
          xml.tag!("ram:DueDateDateTime") do
            xml.tag!("udt:DateTimeString", @invoice.due_date.strftime("%Y%m%d"), format: "102")
          end
        end

        items_by_vat = @invoice.invoice_items.group_by(&:vat_rate)
        items_by_vat.each do |rate, items|
          # Calcul des sommes pour ce taux précis
          base_amount = items.sum(&:total_ht)
          tax_amount = items.sum(&:total_vat)

          xml.tag!("ram:ApplicableTradeTax") do
            xml.tag!("ram:CalculatedAmount", format('%.2f', tax_amount))
            xml.tag!("ram:TypeCode", "VAT")
            xml.tag!("ram:BasisAmount", format('%.2f', base_amount))
            xml.tag!("ram:CategoryCode", "S") # S = Standard, à adapter si auto-liquidation (AE) ou de l'exonération (E)
            xml.tag!("ram:RateApplicablePercent", format('%.2f', rate))
          end
        end

        # Totaux Finaux (MonetarySummation)
        xml.tag!("ram:SpecifiedTradeSettlementHeaderMonetarySummation") do
          xml.tag!("ram:LineTotalAmount", format('%.2f', @invoice.total_ht)) # Somme des lignes
          xml.tag!("ram:TaxBasisTotalAmount", format('%.2f', @invoice.total_ht)) # Base taxable
          xml.tag!("ram:TaxTotalAmount", format('%.2f', @invoice.total_vat), currencyID: "EUR")
          xml.tag!("ram:GrandTotalAmount", format('%.2f', @invoice.total_ttc)) # TTC final
          xml.tag!("ram:DuePayableAmount", format('%.2f', @invoice.total_ttc)) # Reste à payer
        end

      end
    end
  end
end
