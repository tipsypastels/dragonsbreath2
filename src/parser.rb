class Parser
  def initialize(program)
    @lines  = program.split(/\n/)
    @memory = Memory.new
  end
  
  def parse
    lines.each_with_index { |line, i|
      parse_line(line, i)
    }

    memory.lines
  end
  
  private
  
  attr_reader :lines, :memory

  def parse_line(text, number)
    Line::Parser.new(text, number, memory).parse
  end
end