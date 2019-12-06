require "test_helper"
require "minitest/mock"

module Cases
  class GenerateContractPdfTests < ActiveSupport::TestCase
    test "generates a pdf" do
      kase = Case.stub(
        documents: [
          Document.stub(
            source_url: Program::Contract::Wrap1k
          )
        ]
      )

      kase.select_document(0)

      render_html = Minitest::Mock.new
        .expect(:call, "<p>test</p>", [String, Hash])

      generate_contract_pdf = GenerateContractPdf.new(
        render_html: render_html,
        render_pdf: ->(html, _) { html }
      )

      file = generate_contract_pdf.(kase)
      assert_equal(file.data, "<p>test</p>")
      assert_equal(file.name, "contract.pdf")
      assert_equal(file.mime_type, "application/pdf")
    end

    test "generates a meap pdf" do
      kase = Case.stub(
        documents: [
          Document.stub(
            source_url: Program::Contract::Meap
          )
        ]
      )

      kase.select_document(0)

      generate_contract_pdf = GenerateContractPdf.new(
        render_html: ->(_, _) { "" },
        render_pdf: ->(html, _) { html }
      )

      assert_nothing_raised do
        generate_contract_pdf.(kase)
      end
    end

    test "generates a wrap pdf" do
      kase = Case.stub(
        documents: [
          Document.stub(
            source_url: Program::Contract::Wrap3h
          )
        ]
      )

      kase.select_document(0)

      generate_contract_pdf = GenerateContractPdf.new(
        render_html: ->(_, _) { "" },
        render_pdf: ->(html, _) { html }
      )

      assert_nothing_raised do
        generate_contract_pdf.(kase)
      end
    end

    test "does not generate a case with an invalid source url" do
      kase = Case.stub(
        documents: [
          Document.stub(
            source_url: "test"
          )
        ]
      )

      kase.select_document(0)

      generate_contract_pdf = GenerateContractPdf.new

      assert_raises do
        generate_contract_pdf.(kase)
      end
    end
  end
end
