class Line
  def self.generate_id
    SecureRandom.uuid
  end

  attr_accessor :id, 
                :parent_id,
                :number,
                :indent,
                :command,
                :parameters,
                :children,
                :identity,
                :bundling_group,
                :wrapper

  def initialize(number, command, parameters, indent, children: [])
    @id         = Line.generate_id
    @number     = number
    @identity   = [number]
    @command    = command
    @parameters = parameters
    @indent     = indent
    @children   = children
  end

  def to_engine
    return command unless parameters?
    "#{command} #{parameters.map(&:to_engine).join(', ')}"
  end

  def to_h
    { 
      id: id,
      parent_id: parent_id,
      command: command,
    }.tap do |hash|
      hash[:parameters] = parameters.to_a if parameters?
      hash[:children] = children.to_a     if children?
    end
  end

  def param_count
    return 0 unless parameters?
    parameters.length
  end

  delegate :inspect, :to_json, to: :to_h

  def push(child, skip_identity: false)
    unless skip_identity
      child.identity = [*identity, child.number]
    end
    
    child.parent_id = id
    children.push(child)
  end

  def to_wrapped_line(wrapper)
    dup.tap do |_wrapped|
      _self = dup

      _wrapped.id = Line.generate_id
      _wrapped.wrapper = wrapper
      _wrapped.command = wrapper.name
      _wrapped.children = [_self]
      _wrapped.parameters = []

      _self.parent_id = _wrapped.id
    end
  end

  def transform_children!
    @children = yield(children)
    self
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

  def take_children
    children  = @children
    @children = nil
    children
  end

  protected

  attr_accessor :identity
end