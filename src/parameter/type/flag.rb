class Parameter::Type::Flag < Parameter::Type::Base
  def type_of_goto
    value[:inverse] ? :unset : :set
  end
end