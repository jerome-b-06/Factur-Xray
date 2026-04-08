[![CI](https://github.com/jerome-b-06/Factur-Xray/actions/workflows/ci.yml/badge.svg)](https://github.com/jerome-b-06/Factur-Xray/actions/workflows/ci.yml)
[![Dependabot Updates](https://github.com/jerome-b-06/Factur-Xray/actions/workflows/dependabot/dependabot-updates/badge.svg)](https://github.com/jerome-b-06/Factur-Xray/actions/workflows/dependabot/dependabot-updates)
# Electronic Invoicing (Factur-X / ZUGFeRD) - Advanced POC

This project is an advanced Proof of Concept (POC) built with Ruby on Rails. It demonstrates the complete lifecycle of European standard electronic invoicing (Factur-X / ZUGFeRD EN 16931).

The application is capable of generating visually appealing PDF invoices, embedding structured XML data (UN/CEFACT CII) to create "Hybrid PDFs", and provides a full validation module to parse and verify incoming electronic invoices.

---

## Features

### 1. Compliant Invoice Generation
Generates electronic invoices for multiple configured companies. The system uses **Ferrum** (Headless Chrome) to render pixel-perfect HTML/Tailwind templates into PDFs, and **HexaPDF** to embed the strictly formatted `factur-x.xml` payload inside the document.

**Current Capabilities:**
- Multi-company support (Seller details, SIRET, VAT).
- Dynamic VAT breakdown (Subtotals by tax rate).
- Accurate UN/CEFACT CII XML generation.
- Hybrid PDF creation (Standard PDF + XML attachment).

**To-Do List:**
- [ ] **PDF/A-3 Archiving Standard:** Upgrade the standard PDF output to strict PDF/A-3b compliance (requires font subsetting, embedded ICC color profiles, and XMP metadata injection).
- [ ] **Complete Buyer Information:** Expand the XML generator to include exhaustive client data (Buyer SIRET, comprehensive routing codes for platforms like Chorus Pro).
- [ ] **Dynamic Tax Categories:** Support specific tax exemption codes (e.g., Auto-liquidation, zero-rated).

### 2. Electronic Invoice Validator
A dedicated module to upload, extract, and validate electronic invoices. It uses **DaisyUI** for a clean interface, extracts the hidden XML using HexaPDF, and parses the business rules using Nokogiri.

**Current Capabilities:**
- PDF parsing and automatic `factur-x.xml` extraction.
- Data extraction mapping (Vendor, Buyer, Totals, VAT breakdowns, Line items).
- Business rule validation (Checking for missing mandatory fields).
- Visual compliance report generation.

** To-Do List:**
- [ ] **Archiving Format Validation:** Integrate a tool (like VeraPDF) to verify that the uploaded document strictly conforms to the PDF/A-3 standard, not just the XML payload.
- [ ] **Math Verification:** Add backend logic to strictly verify that `Sum of line items + Taxes == Grand Total`.
- [ ] **XML Schema (XSD) Validation:** Validate the extracted XML against the official EN 16931 XSD schemas before parsing business rules.

---

## Tech Stack

* **Framework:** Ruby on Rails 8+
* **PDF Rendering:** `ferrum` (Headless Chrome)
* **PDF Manipulation:** `hexapdf` (For XML embedding and extraction)
* **XML Parsing:** `builder` (Generation) & `nokogiri` (Parsing)
* **Frontend:** Tailwind CSS + DaisyUI components
* **Testing:** RSpec, Capybara (System tests)

---

## Quick Start with Docker

This project is fully containerized to ensure all dependencies (Ruby, Node.js, PostgreSQL, and Chromium) are perfectly configured.

### 1. Build and Start
Run the following command to build the image and start the services (Rails + PostgreSQL):
```bash
docker-compose up --build
