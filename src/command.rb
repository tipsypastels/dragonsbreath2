class Command
  LIST = {
    lock: Lock
  }
  
  def self.[](name)
    LIST[name.to_sym]
  end

  attr_reader :line, :parent, :transpiler, :builder
  delegate :command, 
           :parameters,
           :children,
           :parameters?,
           :children?,
           to: :line

  def initialize(line, parent, transpiler)
    @line = line
    @parent = parent
    @transpiler = transpiler
    @builder = Transpiler::Builder.new(self)
  end

  def prepare
    enforce
    render || builder
  end  

  def enforce
    expecter = Transpiler::Parameters::Expecter
      .new(self)

    expect_params(expecter)
    expecter.enforce(parameters)
  end

  def enforce_params(p)
  end

  def yield_children
    Transpiler.new(children, self).transpile
  end
end