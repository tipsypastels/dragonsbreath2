class Command::Builtins::Script < Command
  def expect_params(p)
    p.name :token
    p.scope :scope, optional: true
  end

  def render
    create_subscript Script::Types::Code,
      scope: parameters.scope
  end
end