module Wrappers
  module_function

  def reset!
    IN_PROGRESS.delete_if { true }
  end

  IN_PROGRESS = {}

  def wrap_compatible_nodes(lines)
    [].tap do |output|
      lines.each do |line|
        line.transform_children!(&method(:wrap_compatible_nodes))

        if (wrapper = Wrapper.find(line))
          find_or_create_wrapped_line(line, wrapper, &output.method(:push))
        else
          output.push(line)
        end
      end
    end
  end

  def find_or_create_wrapped_line(line, wrapper)
    last = IN_PROGRESS[line.indent]
    add_to_existing = last
      &.wrapper
      &.validate_merge?(line)

    if add_to_existing
      last.push(line, skip_identity: true)
    else
      wrapped_line = line.to_wrapped_line(wrapper)
      IN_PROGRESS[line.indent] = wrapped_line
      yield wrapped_line
    end
  end
end