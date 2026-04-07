# frozen_string_literal: true

class PdfGenerator
  def initialize(html_content)
    @html_content = html_content
  end

  def generate
    browser = Ferrum::Browser.new(
      browser_options: { "no-sandbox": nil, "disable-setuid-sandbox": nil, "disable-dev-shm-usage": nil },
      timeout: 30
    )

    begin
      page = browser.create_page
      page.content = @html_content
      sleep 0.5

      pdf_data = page.pdf(
        format: :A4,
        print_background: true,
        margin: { top: "1cm", bottom: "1cm", left: "1cm", right: "1cm" }
      )
      Base64.decode64(pdf_data)

    ensure
      browser.quit
    end
  end
end
