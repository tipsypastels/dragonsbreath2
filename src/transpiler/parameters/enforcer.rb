class Transpiler::Parameters::Enforcer
  attr_reader :command, :expected, :actual

  def initialize(command, expected, actual)
    @command  = command
    @expected = expected
    @actual   = actual
  end

  def enforce
    if actual.length > expected.length
      raise DbrError::Enforcer::Parameters::TooMany
        .new(command, expected, actual)
    end

    expected.zip(actual).each_with_index { |(expectation, param), i|
      if !param && !expectation.optional
        raise DbrError::Enforcer::Parameters::Missing
          .new(command, expectation)
      end

      unless !param || param.type.in?(expectation.types)
        raise DbrError::Enforcer::Parameters::WrongType
          .new(command, expectation, param)
      end

      actual.bind_named_parameter(expectation.name, i)
    }
  end
end