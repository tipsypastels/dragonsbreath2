class Line::Parser
  INDENT = '  '
  COMMENT = '#'

  def initialize(text, number, memory)
    @text   = text.gsub(/#{COMMENT}\s*(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$).*$/, '')
    @number = number
    @memory = memory
  end

  def parse
    return if effectively_blank?

    stripped_text = text
      .gsub(/^\s*/, '')
      .gsub(/\r$/, '')

    if stripped_text.match?(/^".*"$/)
      stripped_text = "say #{text}"
    end
    
    command = stripped_text.split(' ').first
    parameters = stripped_text
       .slice((command.length + 1)..-1)
      &.split(/\s*,\s*(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)/)
      &.map(&method(:parse_parameter))
      &.yield_self(&Parameter::List.method(:new))

    line = Line.new(
      number, 
      command, 
      parameters, 
      indent,
    )

    memory.push(line)
  end

  private

  def parse_parameter(parameter)
    Parameter::Parser.new(parameter).parse
  end
  
  attr_reader :text, :number, :memory

  def indent
    @indent ||= begin
      /^(\s*)/.match text
      $1.length / INDENT.length
    end
  end

  def effectively_blank?
    text.length.zero? || /^[^\S]\n?$/.match?(text)
  end
end