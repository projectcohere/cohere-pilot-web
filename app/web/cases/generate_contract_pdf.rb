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
      document = kase.selected_document
      if document.nil?
        raise "can't generate contract without a selected document"
      end

      variant_path = case document.source_url&.to_sym
      when Program::Contract::Meap
        "cases/pdfs/meap"
      when Program::Contract::Wrap3h
        "cases/pdfs/wrap_3h"
      when Program::Contract::Wrap1k
        "cases/pdfs/wrap_1k"
      end

      if variant_path.nil?
        raise "can't generate contract with an invalid source_url: #{document}"
      end

      pdf_html = @render_html.(variant_path, {
        date: Date.today,
        kase: kase
      })

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
        ContractsController.renderer.render(name,
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
        pdf = PDFKit.new(html,
          footer_center: "Page [page] of [toPage]",
          footer_font_size: 8,
          footer_font_name: "Euclid Flex"
        )

        pdf.to_file("#{output_dir}/#{tmp_filename}.pdf")
      end
    end
  end
end
