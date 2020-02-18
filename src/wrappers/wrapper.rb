class Wrappers::Wrapper
  def self.find(line)
    LIST.values.detect { |wrapper| wrapper.include?(line) }
  end

  LIST = {}

  attr_reader :name, :commands

  def initialize(name, commands, &validator)
    @name      = name
    @commands  = commands
    @validator = validator

    LIST[name] = self
  end

  def validate_merge?(line)
    last = Wrappers::IN_PROGRESS[line.indent]
    
    include?(line) && line.indent == last.indent && line.parent_id == last.parent_id && begin
      validator ? validator.call(line, last) : true
    end
  end

  def include?(line)
    line.command.in? commands
  end

  private

  attr_reader :validator
end

Wrappers::Wrapper.new('text_bundle', %w|say sayraw ask|) { |line, last_wrapped_line|
  line.param_count == last_wrapped_line.children.last.param_count
}

Wrappers::Wrapper.new('cond_bundle', %w|if else_if elif else when|)