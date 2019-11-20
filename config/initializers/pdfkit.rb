PDFKit.configure do |config|
  config.default_options = {
    # see: https://github.com/wkhtmltopdf/wkhtmltopdf/issues/2171
    zoom: Rails.env.production? ? 0.75 : 1
  }
end
