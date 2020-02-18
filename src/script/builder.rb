module Script::Builder
  def add_line(*lines)
    @output += lines
  end
  alias add_lines add_line
end