class Transpiler::Builder
  attr_reader :command, :result
  delegate :line,
           :parameters,
           :children,
           :parameters?,
           :children?,
           to: :command

  def initialize(command)
    @command = command
    @result  = []
  end

  def add_line(*lines)
    result.concat(lines)
    self
  end
  alias :add_lines :add_line

  def yield_each_line
    children.each_with_index { |child, i|
      result = Transpiler.new([child], line)
      yield(result, i, self)
    }

    self
  end

  def add_goto(opts)
    yielded_lines = (opts[:lines] || command.yield_children).split("\n")

    subscript_name = Script.current
      .subscript_name(opts[:type])

    goto = case opts[:type]
    when :code
      if opts[:variant] == :switch
        "case #{opts[:idx]}, #{subscript_name}"
      else
        "goto_if_#{opts[:if]} #{subscript_name}"
      end
    when :text
      "msgbox #{subscript_name}, #{Msgbox.current}"
    when :movement
      "applymovement #{opts[:event]}, #{subscript_name}"
    end

    add_line(goto)

    Script.current.add_subscript(
      name: subscript_name,
      type: opts[:type],
      texts: yielded_lines,
      source: line,
      source_parent: command.parent
    )

    self
  end

  def each_subscript(type: nil)
    unless Script.current
      throw DbrError::Commands::MissingScript
        .new(command)
    end

    Script.current.subscripts.each { |subscript|
      next if type && subscript.type != type
      next unless subscript.descendant_of?(line)

      yield subscript
    }
    self
  end

  def each_child
    children.each_with_index { |child, i|
      yield child, i, self
    }
    self
  end

  def yield_children
    results.push command.yield_children
    self
  end
end