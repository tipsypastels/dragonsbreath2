class Memory
  attr_reader :lines, :chain

  def initialize
    @lines = []
    @chain = []
  end

  def push(line)
    push_to_chain = false
    last_line = chain.last

    bundle(line, last_line) || begin
      push_to_chain = true

      if line.indent < 1
        lines.push(line)
      else
        parent = find_parent(line.indent)
  
        unless parent
          raise "unexpected indent #{line.number}"
        end
  
        parent.push(line)
      end
    end

    chain.push(line) if push_to_chain
  end

  private

  COMMANDS_TO_BUNDLE = %w|say smart_say ask|
  BUNDLING_KEY = '___bundle___'

  def bundle(line, last_line)
    unless last_line && line.indent == last_line.indent
      return
    end

    unless line.command.in?(COMMANDS_TO_BUNDLE)
      return
    end

    if last_line.command == BUNDLING_KEY
      last_line.push(line, skip_identity: true)
    elsif last_line.command.in?(COMMANDS_TO_BUNDLE) && line.param_count == last_line.param_count
      last_line.bundle_with(line)
    end
  end

  def find_parent(indent)
    chain.reverse.detect { |line|
      indent == line.indent + 1
    }
  end
end