class Script
  include Allowing, Sourced, Scoped, Builder, Executable

  cattr_accessor :top_level
  attr_reader :lines, :source, :parent, :output
  attr_accessor :children

  def initialize(lines, source: nil, parent: nil, scope: nil, children: [])
    @lines    = lines
    @source   = source
    @parent   = parent || Script.top_level
    @scope    = scope  || default_scope
    @output   = []
    @children = children

    @parent&.children&.push(self)
    ensure_source
  end

  def name
    source.parameters.name
  end

  private
end