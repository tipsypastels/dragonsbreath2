class Memory
  attr_reader :lines, :chain

  def initialize
    @lines = []
    @chain = []
  end

  def push(line)
    destination_for(line).push(line)
    chain.push(line)
  end

  private

  def destination_for(line)
    return lines if line.indent.zero?

    chain.reverse.detect { |chain_line|
      line.indent == chain_line.indent + 1
    } || raise("unexpected indent on line #{line.number}")
  end
end