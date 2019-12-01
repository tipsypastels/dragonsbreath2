class Parameter::Type::String < Parameter::Type::Base
  def to_engine
    "\"#{super}\""
  end
end