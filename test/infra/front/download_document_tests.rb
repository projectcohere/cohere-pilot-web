require "test_helper"

module Front
  class DownloadDocumentTests < ActiveSupport::TestCase
    test "downloads a document" do
      VCR.use_cassette("front--download_document") do
        document_url = "https://api2.frontapp.com/download/fil_atg8kcn"
        download_document = DownloadDocument.new
        file = download_document.(document_url)
        assert_not_nil(file)
      end
    end
  end
end
