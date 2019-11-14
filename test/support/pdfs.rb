module Support
  module Pdfs
    def text_from_pdf_file(file)
      pdf_data = file.download
      pdf = HexaPDF::Document.new(io: StringIO.new(pdf_data))

      pdf_processor = StringProcessor.new
      pdf.pages.each do |page|
        page.process_contents(pdf_processor)
      end

      pdf_processor.text.gsub("\t", " ")
    end

    class StringProcessor < HexaPDF::Content::Processor
      def text
        @text ||= ""
      end

      def show_text(data)
        text << decode_text(data)
      end
    end
  end
end

ActionDispatch::IntegrationTest.include(Support::Pdfs)
