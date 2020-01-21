require "test_helper"
require "minitest/mock"

module Cases
  class AttachDocumentFileTests < ActiveSupport::TestCase
    test "attaches a file" do
      kase = Case.stub(
        documents: [
          Document.stub
        ]
      )

      case_repo = Minitest::Mock.new
        .expect(
          :find_with_document,
          kase,
          ["case-id", "document-id"]
        )
        .expect(
          :save_selected_attachment,
          nil,
          [kase]
        )

      attach_file = AttachDocumentFile.new(
        generate_file: ->(_) { "test-file" },
        case_repo: case_repo
      )

      attach_file.("case-id", "document-id")
      assert_equal(kase.selected_document.new_file, "test-file")
    end
  end
end
