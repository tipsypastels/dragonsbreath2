class Script::Types::Text < Script
  ALLOWED_COMMANDS = %i|say ask smart_say text_bundle|

  def default_scope
    :local
  end
end