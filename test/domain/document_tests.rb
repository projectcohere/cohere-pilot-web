require "test_helper"

class DocumentTests < ActiveSupport::TestCase
  test "signs a contract" do
    contract = Program::Contract.stub(
      variant: :wrap_3h
    )

    document = Document.sign_contract(contract)
    assert_equal(document.id, Id::None)
    assert_equal(document.classification, :contract)
    assert_equal(document.source_url, "wrap_3h")
  end
end
