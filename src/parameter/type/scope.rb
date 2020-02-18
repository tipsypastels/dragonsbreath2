module Parameter::Type
  class Scope < Base
    def to_engine
      # todo error types
      raise NotImplementedError, "Cannot use #to_engine on a scope type"
    end

    def transform_value(value)
      value.to_sym
    end

    %i|global local|.each { |scope|
      define_method(:"#{scope}?") {
        value == scope
      }
    }
  end
end