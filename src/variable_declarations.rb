class VariableDeclarations
  attr_accessor :at_start_of_file

  ALLOWED_TYPES = %i|it scope number string constant token|

  def initialize(list = {})
    @at_start_of_file = true
    
    @list = list
      .transform_values(&method(:parse))
      .with_indifferent_access
  end

  delegate :fetch, to: :list

  def add(name, raw_value)
    unless at_start_of_file
      raise "Constant declarations must be made at the beginning of the file and cannot be changed."
    end

    list[name] = parse(raw_value)
  end

  private

  attr_reader :list

  # don't pass self here, variables can't reference each other? 
  def parse(value, restrictions: ALLOWED_TYPES)
    Parameter::Parser.new(value).parse(restrictions: restrictions)
  end

  class Null
    def fetch(*)
      raise "Cannot fetch from a null variable declarations object"
    end
  end
end