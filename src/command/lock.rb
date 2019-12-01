class Command::Lock < Command
  def render
    if children?
      builder
        .add_line(lock)
        .yield_children
        .each_subscript(type: :code) { |s|
          s.texts.push(release)
        }
        .add_line(release)
    else
      beginning
    end
  end

  def lock
    'lock'
  end

  def release
    'release'
  end
end