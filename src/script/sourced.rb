module Script::Sourced
  private

  def allow_nil_as_source?
    false
  end

  def ensure_source
    return if source || allow_nil_as_source?
    raise DbrError::Scripts::NoScriptSource.new(self)
  end
end