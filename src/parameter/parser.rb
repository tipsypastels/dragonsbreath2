class Parameter::Parser
  def initialize(value)
    @value = value.strip
  end

  def parse
    return if blank?

    case value
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
        check: reparse($1), 
        inverse: value[/^un/].present?,
      }
    else
      raise "Could not parse #{value}"
    end
  end

  private

  attr_reader :value, :captures
  delegate :blank?, to: :value

  def create_type(type, value = nil)
    Parameter::Type.create(type, value)
  end

  def comparison(*symbols)
    /^(.+)\s*(?:#{symbols.join('|')})\s*(.+)$/
  end

  def reparse(subvalue)
    Parameter::Parser.new(subvalue).parse
  end
end