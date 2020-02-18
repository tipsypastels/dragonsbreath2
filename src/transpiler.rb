class Transpiler
  def self.transpile(*a)
    new(*a).transpile
  end

  def initialize(lines, script:, parent: nil)
    @lines  = lines
    @script = script
    @parent = parent
  end
  
  def transpile
    lines.map(&method(:transpile_line))
  end

  private

  attr_reader :lines, :script, :parent

  def transpile_line(line)
    builtin = Command[line.command]

    if builtin
      builtin.new(
        line, 
        parent: parent, 
        script: script || Script.top_level, 
        transpiler: self,
      ).prepare
    else
      script.add_line(line.to_engine)
    end
  end
end