class Parameter::Type::Number < Parameter::Type::Base
  def transform_value(value)
    float = value.to_f
    int   = value.to_i

    if float == int
      int
    else
      float
    end
  end
end