module Command::Hierarchy
  def create_subscript(new_script_class, scope: nil)
    new_script_class.new(line.take_children,
      source: line,
      parent: script,
      scope: scope,
    )
  end
end