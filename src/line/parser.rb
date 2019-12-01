class Line::Parser
  INDENT = '  '

  def initialize(text, number, memory)
    @text   = text
    @number = number
    @memory = memory
  end

  # TODO str_comma
  def parse
    return if effectively_blank?

    stripped_text = text
      .gsub(/^\s*/, '')
      .gsub(/\r$/, '')
    
    command = stripped_text.split(' ').first
    parameters = stripped_text
      .slice((command.length + 1)..-1)
      &.split(/\s*,\s*(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)/)
      &.map(&method(:parse_parameter))
      &.compact

    line = Line.new(
      number, 
      command, 
      parameters, 
      indent
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