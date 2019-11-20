PDFKit.configure do |config|
  # workarounds for rendering differences on linux/heroku
  # see: https://github.com/wkhtmltopdf/wkhtmltopdf/issues/2171
  page_zoom = Rails.env.production? ? 0.75 : 1
  page_margin = "#{0.75 / page_zoom}in"

  config.default_options = {
    quiet: true,
    disable_smart_shrinking: false,
    page_size: "Letter",
    encoding: "UTF-8",
    zoom: page_zoom,
    margin_top: page_margin,
    margin_bottom: page_margin,
    margin_left: page_margin,
    margin_right: page_margin
  }
end
