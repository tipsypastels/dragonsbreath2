class Command::Builtins::If < Command
  def expect_params(p)
    p.cond %i|eq|
  end

  def render
    subscript = create_subscript(Subscript::Types::Code)

    if has_else?
      goto_method = :goto

      unless siblings.before.chain_search(:if).present?
        siblings.after.chain_search(:else_if, :else).after.move_to()
      end
    else
      goto_method = :call
    end

    <<~RESULT
      compare #{params.cond.value.left}, #{params.cond.value.right}
      #{goto_method}_if_#{params.cond.type_of_goto}
    RESULT
  end

  private

  def has_else?
    siblings.after.chain_search(:else_if, :else).present?
  end
end