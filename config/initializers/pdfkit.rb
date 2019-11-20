PDFKit.configure do |config|
  config.default_options = {
    quiet: true,
    disable_smart_shrinking: false,
    page_size: "Letter",
    encoding: "UTF-8",
    margin_top: "0.75in",
    margin_bottom: "0.75in",
    margin_left: "0.75in",
    margin_right: "0.75in",
    # workarounds for rendering differences on linux/heroku
    # see: https://github.com/wkhtmltopdf/wkhtmltopdf/issues/2171
    zoom: Rails.env.production? ? 0.75 : 1
  }
end
