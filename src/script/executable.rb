module Script::Executable
  extend ActiveSupport::Concern

  class_methods do
    def execute(*a, **b)
      new(*a, **b).execute
    end
  end

  def execute
    add_line(beginning) if respond_to?(:beginning)
    
    Transpiler.transpile(lines, script: self, parent: source)
    add_lines(children.collect(&:execute).flatten)

    add_line(ending) if respond_to?(:ending)

    output
  end
end