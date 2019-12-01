class Script < Struct.new()
  cattr_accessor :current
  attr_reader :manager, :parent, :type, :name, :body

  def initialize(manager, parent, type, name, body)
    @manager = manager
    @parent  = parent
    @type    = type
    @name    = name
    @body    = body

    manager.push(self)
  end

  def create_subscript(type)
    name = "_"
  end

  def name
    body.parameters.first.value
  end

  def subscripts
    manager.scripts.detect { |s|
      s.parent == self
    }
  end
end