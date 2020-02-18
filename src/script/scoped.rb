module Script::Scoped
  def scope_to_engine
    scope.global? ? '::' : ':'
  end
end