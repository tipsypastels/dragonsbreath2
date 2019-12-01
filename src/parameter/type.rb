module Parameter::Type
  def self.create(type, value)
    self.const_get(type.to_s.classify).new(value)
  end
end