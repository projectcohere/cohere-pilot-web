require "test_helper"

class DocumentTests < ActiveSupport::TestCase
  test "uploads an attachment" do
    document = Document.upload(
      "https://website.com/image.jpg",
      case_id: 1
    )

    assert_equal(document.classification, :unclassified)
  end

  test "generates a contract" do
    document = Document.generate_contract(
      case_id: 2
    )

    assert_equal(document.classification, :contract)
  end
end
