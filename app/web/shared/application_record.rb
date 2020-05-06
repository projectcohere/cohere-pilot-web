class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # -- config --
  class << self
    # -- config/callbacks
    def inherited(child)
      child.set_table_name!
      super
    end

    # -- config/associations
    def belongs_to(name, *args, record: nil, child: false, **kwargs)
      set_class_name!(kwargs, singularize(record || name), child)
      super(name, *args, **kwargs)
    end

    def has_many(name, *args, record: nil, child: false, **kwargs)
      set_class_name!(kwargs, singularize(record || name), child)
      set_foreign_key!(kwargs)
      super(name, *args, **kwargs)
    end

    def has_one(name, *args, record: nil, child: false, **kwargs)
      set_class_name!(kwargs, singularize(record || name), child)
      set_foreign_key!(kwargs)
      super(name, *args, **kwargs)
    end

    def has_and_belongs_to_many(name, *args, record: nil, child: false, **kwargs)
      set_class_name!(kwargs, singularize(record || name), child)
      set_foreign_key!(kwargs)
      set_association_foreign_key!(kwargs, singularize(name))
      super(name, *args, **kwargs)
    end

    # -- config/naming
    # sets `table_name` based on the enclosing entity's name
    def set_table_name!
      self.table_name = model_name.plural
    end

    # sets the default `class_name` in the association args based
    # on the association name
    private def set_class_name!(args, name, child)
      if not args.key?(:class_name)
        base = if child
          "/#{find_root.model_name.element}"
        end

        args[:class_name] = "#{base}/#{name}/record".camelize
      end
    end

    # sets the default `foreign_key` in the association args based on
    # the enclosing entity's name
    private def set_foreign_key!(args)
      # hack to filter out ActiveStorage assosciation definitions
      if args[:as] == :record
        return
      end

      if not args.key?(:foreign_key)
        args[:foreign_key] = :"#{model_name.element}_id"
      end
    end

    # sets the default `association_foreign_key` in the association args
    # based on association name
    private def set_association_foreign_key!(args, name)
      if not args.key?(:association_foreign_key)
        args[:association_foreign_key] = :"#{name}_id"
      end
    end

    # -- config/helpers
    private def find_root
      root = self
      while root.module_parent != Object
        root = root.module_parent
      end

      return root
    end

    private def singularize(name)
      return name.to_s.singularize
    end
  end

  # -- ActiveModel::Naming --
  def self.model_name
    @_model_name ||= begin
      ActiveModel::Name.new(self, nil, module_parent.name)
    end
  end
end
