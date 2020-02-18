class Script::Types::MapScripts < Script
  ALLOWED_COMMANDS = %i|
    on_load on_frame_table on_transition
    on_warp_into_map_table on_resume
  |

  private

  def default_scope
    :global
  end
end