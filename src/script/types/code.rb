class Script::Types::Code < Script
  ALLOWED_COMMANDS = %i|
    lock
  |

  private
  
  def allows_unrecognized?
    true
  end

  def default_scope
    :global
  end

  def ending
    :end
  end
end