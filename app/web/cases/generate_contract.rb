module Cases
  class GenerateContract < ::Command
    # -- lifetime --
    def initialize(
      render_html: RenderHtml.new,
      render_pdf: RenderPdf.new
    )
      @render_html = render_html
      @render_pdf = render_pdf
    end

    # -- command --
    def call(kase)
      document = kase.selected_document
      if document.nil?
        raise "can't generate contract without a selected document"
      end

      html_path = "programs/contracts/#{document.source_url&.to_sym}"
      html = @render_html.(html_path, {
        view: Cases::Views::Repo.map_contract(kase),
      })

      return FileData.new(
        data: @render_pdf.(html, kase.id.to_s),
        name: "contract.pdf",
        mime_type: "application/pdf"
      )
    end

    # -- children --
    class RenderHtml
      # -- command --
      def call(name, locals)
        Programs::ContractsController.renderer.render(name,
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
