require "test_helper"

module Front
  class DownloadAttachmentTests < ActiveSupport::TestCase
    test "downloads a document file" do
      VCR.use_cassette("front--attachment") do
        document_url = "https://api2.frontapp.com/download/fil_atg8kcn"
        download_document = DownloadAttachment.new

        file = download_document.(document_url)
        assert_not_nil(file)
        assert_equal(file.name, "0.jpeg")
        assert_equal(file.mime_type, "image/jpeg")
      end
    end
  end
end
