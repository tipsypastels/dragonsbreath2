module Parameter::Type
  class BaseComparison < Base
    def transform_value(value)
      Comparison.new(
        parse(value[:left]),
        parse(value[:right]),
      )
    end

    def to_h
      super.tap do |hash|
        hash[:value] &&= hash[:value].to_h
          .map { |key, value| [key, value.to_h] }.to_h
      end
    end

    def to_engine
      # todo error types
      raise NotImplementedError, "Cannot use #to_engine on a comparison type"
    end

    Comparison = Struct.new(:left, :right)
  end
end