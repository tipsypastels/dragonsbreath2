module Parameter::Type
  class Le < BaseComparison
    def type_of_goto
      :le
    end
  end
end