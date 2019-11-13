module Cases
  class GenerateContractPdf
    def initialize(
      render_html: RenderHtml.new,
      render_pdf: RenderPdf.new
    )
      @render_html = render_html
      @render_pdf = render_pdf
    end

    def call(kase)
      locals = {
        name: "you"
      }

      pdf_html = @render_html.("cases/pdfs/contract", locals)
      pdf_file = @render_pdf.(pdf_html, kase.id.to_s)

      FileData.new(
        data: pdf_file,
        name: "contract.pdf",
        mime_type: "application/pdf"
      )
    end

    # -- child services --
    class RenderHtml
      # -- command --
      def call(name, locals)
        ApplicationController.renderer.render(name,
          layout: nil,
          locals: locals
        )
      end
    end

    class RenderPdf
      # -- command --
      def call(html, tmp_filename)
        output_dir = "./tmp/pdfs"

        # ensure dir exists
        FileUtils.mkdir_p(output_dir)

        # write pdf to file
        pdf = PDFKit.new(html, page_size: "Letter")
        pdf.to_file("#{output_dir}/#{tmp_filename}.pdf")
      end
    end
  end
end