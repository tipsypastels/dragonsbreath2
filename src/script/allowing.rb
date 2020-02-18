module Script::Allowing
  def allows?(command)
    command.in? allowed_commands
  end

  def allows!(command)
    return if allows? command
    raise DbrError::Scripts::WrongTopLevel.new(self, command)
  end

  
  private
  
  def allows_unrecognized?
    false
  end
  
  def allowed_commands
    ALLOWED_COMMANDS
  end
end