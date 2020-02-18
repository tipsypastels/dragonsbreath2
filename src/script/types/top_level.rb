class Script::Types::TopLevel < Script
  ALLOWED_COMMANDS = %i|
    const
    script
    text_script
    movement_script
    map_scripts
  |

  def initialize(*)
    super
    Script.top_level = self
  end

  def allow_nil_as_source?
    true
  end

  def default_scope
    nil
  end
end