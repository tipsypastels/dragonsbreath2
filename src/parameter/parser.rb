class Parameter::Parser
  def initialize(value, vars = VariableDeclarations::Null.new)
    @value = value.strip
    @vars  = vars 
  end

  def parse(restrictions: nil)
    return if blank?

    case value
    when /:([a-z0-9_]+)/
      vars.fetch($1)
    when /^it$/
      create_type :it
    when /\((global|local)\)/
      create_type :scope, $1
    when /^(\d*\.?\d*)$/
      create_type :number, $1
    when /^"(.*)"$/
      create_type :string, $1
    when /^[A-Zx0-9_]+$/
      create_type :constant, value
    when /^[a-z0-9_]+$/i
      create_type :token, value
    when comparison('==', '===', 'is', 'eq')
      create_type :eq, { left: $1, right: $2 }
    when comparison('<', 'lt')
      create_type :lt, { left: $1, right: $2 }
    when comparison('>', 'gt')
      create_type :gt, { left: $1, right: $2 }
    when comparison('<=', 'le')
      create_type :le, { left: $1, right: $2 }
    when comparison('>=', 'ge')
      create_type :ge, { left: $1, right: $2 }
    when /^(?:flag|(?:un)?set)\? (.+)$/
      create_type :flag, { 
        check: reparse($1, restrictions: %i|constant token it|), 
        inverse: value[/^un/].present?,
      }
    else
      raise "Could not parse #{value}"
    end.tap do |param|
      if restrictions && !param.type.in?(restrictions)
        raise "Parameter type #{param.type} is not allowed here"
      end
    end
  end

  private

  attr_reader :value, :vars
  delegate :blank?, to: :value

  def create_type(type, value = nil)
    Parameter::Type.create(type, value)
  end

  def comparison(*symbols)
    /^(.+)\s*(?:#{symbols.join('|')})\s*(.+)$/
  end

  def reparse(subvalue, restrictions: nil)
    Parameter::Parser.new(subvalue).parse(restrictions: restrictions)
  end
end