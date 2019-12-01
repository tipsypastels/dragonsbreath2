class DbrError < SyntaxError
  module Memory
    class Indent < DbrError; end
  end

  module Parser
    class UnprocessableParameter < DbrError; end
  end

  module Scripts
    class WrongTopLevel < DbrError; end
  end

  module Enforcer
    module Parameters
      class TooMany < DbrError
        def initialize(command, expected, actual)
          super("#{command} takes #{expected.length} parameters, got #{actual.length}")
        end
      end

      class Missing < DbrError
        def initialize(command, expectation)
          super("Parameter #{expectation.name} was not provided to #{command}")
        end
      end

      class WrongType < DbrError
        def initialize(command, expectation, param)
          super("Parameter for #{command} #{expectation.name} must be one of #{expectation.types.inspect}, got #{param[:type]}")
        end
      end
    end
  end

  module Commands
    class MissingScript
      def initialize(command)
        "Command #{command} must be inside a script body"
      end
    end
  end
end