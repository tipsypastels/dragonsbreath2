class Command
  include Table, Enforcing, Hierarchy, Builder

  attr_reader :line, :parent, :transpiler, :script
  delegate :command, 
           :parameters,
           :children,
           :parameters?,
           :children?,
           to: :line

  def initialize(line, parent:, transpiler:, script:)
    @line = line
    @parent = parent
    @transpiler = transpiler
    @script = script
  end

  def prepare
    enforce
    render.tap { |res| add_line(res) if res.is_a?(String) }
  end  

  def yield_children
    Transpiler.new(children, self).transpile
  end
end