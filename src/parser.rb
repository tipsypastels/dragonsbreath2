class Parser
  def initialize(program)
    @lines  = program.split(/\n/)
    @memory = Memory.new
    @vars   = VariableDeclarations.new
  end
  
  def parse
    lines.each_with_index(&method(:parse_line))
    Wrappers.wrap_compatible_nodes(memory.lines).tap do
      Wrappers.reset!
    end
  end
  
  private
  
  attr_reader :lines, :memory

  def parse_line(text, number)
    Line::Parser.new(text, number, memory, vars).parse
  end
end