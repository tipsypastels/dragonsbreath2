class Transpiler
  def initialize(lines, parent)
    @lines  = lines
    @parent = parent
  end
  
  def transpile
    lines.map(&method(:transpile_line))
  end

  private

  attr_reader :lines, :parent

  def transpile_line(line)
    builtin = Command[line.command]

    if builtin
      builtin.new(line, parent, self).prepare
    else
      line.to_engine
    end
  end
end