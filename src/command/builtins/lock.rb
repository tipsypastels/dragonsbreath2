class Command::Builtins::Lock < Command
  def render
    if children?
      add_line(lock)
      yield_children
      add_line(release)
    else
      add_line(lock)
    end
  end
  
  private

  def lock
    'lock'
  end

  def release
    'release'
  end
end