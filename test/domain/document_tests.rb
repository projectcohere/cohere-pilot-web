require "test_helper"

class DocumentTests < ActiveSupport::TestCase
  test "uploads an attachment" do
    document = Document.upload("https://website.com/image.jpg")
    assert_equal(document.id, Id::None)
    assert_equal(document.classification, :unknown)
  end

  test "signs a contract" do
    document = Document.sign_contract
    assert_equal(document.id, Id::None)
    assert_equal(document.classification, :contract)
  end
end
