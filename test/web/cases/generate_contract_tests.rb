require "test_helper"

module Cases
  class GenerateContractTests < ActiveSupport::TestCase
    test "generates a pdf" do
      kase = Case.stub(
        documents: [
          Document.stub(source_url: Program::Contract::Wrap1k)
        ]
      )

      kase.select_document(0)

      render_html = Minitest::Mock.new
        .expect(:call, "<p>test</p>", [String, Hash])

      generate = GenerateContract.new(
        render_html: render_html,
        render_pdf: ->(html, _) { html }
      )

      file = generate.(kase)
      assert_equal(file.data, "<p>test</p>")
      assert_equal(file.name, "contract.pdf")
      assert_equal(file.mime_type, "application/pdf")
    end

    test "generates a meap pdf" do
      kase = Case.stub(
        documents: [
          Document.stub(source_url: Program::Contract::Meap)
        ]
      )

      kase.select_document(0)

      generate = GenerateContract.new(
        render_html: ->(_, _) { "" },
        render_pdf: ->(html, _) { html }
      )

      assert_nothing_raised do
        generate.(kase)
      end
    end

    test "generates a wrap pdf" do
      kase = Case.stub(
        documents: [
          Document.stub(source_url: Program::Contract::Wrap3h)
        ]
      )

      kase.select_document(0)

      generate = GenerateContract.new(
        render_html: ->(_, _) { "" },
        render_pdf: ->(html, _) { html }
      )

      assert_nothing_raised do
        generate.(kase)
      end
    end

    test "does not generate a case with an invalid source url" do
      kase = Case.stub(
        documents: [
          Document.stub(source_url: "test")
        ]
      )

      kase.select_document(0)

      assert_raises(StandardError) do
        GenerateContract.(kase)
      end
    end
  end
end
