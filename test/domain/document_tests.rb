require "test_helper"

class DocumentTests < ActiveSupport::TestCase
  test "uploads an attachment" do
    document = Document.upload("https://website.com/image.jpg")
    assert_equal(document.id, Id::None)
    assert_equal(document.classification, :unknown)
    assert_equal(document.source_url, "https://website.com/image.jpg")
  end

  test "signs a meap contract" do
    contract = Program::Contract.new(
      program: Program::Name::Meap,
      variant: Program::Contract::Meap
    )

    document = Document.sign_contract(contract)
    assert_equal(document.id, Id::None)
    assert_equal(document.classification, :contract)
    assert_equal(document.source_url, Program::Contract::Meap.to_s)
  end

  test "signs a wrap contract" do
    contract = Program::Contract.new(
      program: Program::Name::Wrap,
      variant: Program::Contract::Wrap1k
    )

    document = Document.sign_contract(contract)
    assert_equal(document.id, Id::None)
    assert_equal(document.classification, :contract)
    assert_equal(document.source_url, Program::Contract::Wrap1k.to_s)
  end
end
