class Line
  attr_reader :number, 
              :command, 
              :parameters,
              :indent,
              :children

  def initialize(number, command, parameters, indent)
    @number     = number
    @identity   = [number]
    @command    = command
    @parameters = parameters
    @indent     = indent
    @children   = []
  end

  def to_engine
    return command unless parameters?
    "#{command} #{parameters.map(&:to_engine).join(', ')}"
  end

  def to_h
    hash = { command: command }
    hash[:parameters] = parameters if parameters?
    hash[:children] = children if children?
    hash
  end

  def param_count
    return 0 unless parameters?
    parameters.length
  end

  delegate :inspect, to: :to_h

  def push(child, skip_identity: false)
    unless skip_identity
      child.identity = [*identity, child.number]
    end
    
    children.push(child)
  end

  def bundle_with(other)
    this = dup

    @command = Memory::BUNDLING_KEY
    @children = [this, other]
    @parameters = []    
  end

  def children?
    children.present?
  end

  def parameters?
    parameters.present?
  end

  def descendant_of?(ancestor)
    identity.include? ancestor.number
  end

  protected

  attr_accessor :identity
end