require "test_helper"
require "minitest/mock"

module Cases
  class GenerateContractPdfTests < ActiveSupport::TestCase
    test "generates a pdf" do
      kase = Case.stub

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
  end
end
