class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # -- config --
  def self.set_table_name!
    self.table_name = model_name.plural
  end

  # -- ActiveModel::Naming --
  def self.model_name
    @_model_name ||= begin
      ActiveModel::Name.new(self, nil, module_parent.name)
    end
  end
end
