module Ext
  module Asserts
    def assert(condition, message)
      if !condition
        trace = caller_locations[1,1][0]
        trace_path = trace.path.delete_prefix("#{Rails.root}/")
        raise(RuntimeError, "#{trace_path}:#{trace.lineno} -- #{message}")
      end
    end
  end
end

Object.include(Ext::Asserts)
