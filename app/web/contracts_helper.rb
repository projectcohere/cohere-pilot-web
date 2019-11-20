module ContractsHelper
  # -- impls --
  # -- impls/css
  def styles(filename)
    asset_path = Rails.application.assets_manifest.assets[filename]
    Rails.root.join("public", "assets", asset_path).read
  end

  # -- impls/elements
  def title(text)
    tag.h1(class: "ContractSection-title") do
      text.html_safe +
      tag.div(class: "ContractSection-titleBorder")
    end
  end

  def field(hint, value = "", **kwargs)
    a_class = kwargs.delete(:class)

    tag.label(class: "#{a_class} ContractField") do
      hint_tag = tag.p(hint, class: "ContractField-hint")

      input_tags = if not value.is_a?(Array)
        field_input(value)
      else
        value.each_with_object(String.new).with_index do |(v, m), i|
          m << field_input(v, class: "#{a_class}-#{i}")
        end
      end

      hint_tag + input_tags.html_safe
    end
  end

  def field_input(value, **kwargs)
    a_class = kwargs.delete(:class)

    tag.div(class: "#{a_class} ContractField-input") do
      tag.p(value, class: "ContractField-value") +
      tag.div(class: "ContractField-border")
    end
  end
end
