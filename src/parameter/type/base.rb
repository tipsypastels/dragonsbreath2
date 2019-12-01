class Parameter::Type::Base
  attr_reader :value

  def initialize(value = nil)
    @value  = transform_value(value)
  end

  def type
    self.class.name
      .demodulize
      .downcase
      .to_sym
  end
  
  def to_engine
    value.to_s
  end

  def to_h
    hash = { type: type }
    hash[:value] = value if value?
    hash
  end

  delegate :inspect, :to_s, to: :to_h

  def value?
    value.present?
  end

  private

  def transform_value(value)
    value
  end
  
  def parse(subvalue)
    Parameter::Parser.new(subvalue).parse
  end
end