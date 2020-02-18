class Script::Types::Movement < Script
  ALLOWED_COMMANDS = %i|
  |

  private

  def allows_unrecognized?
    true
  end

  def default_scope
    :local
  end

  def ending
    :step_end
  end
end