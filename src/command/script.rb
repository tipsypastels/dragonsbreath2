class Command::Script < Command
  def expect_params(p)
    p.name :token
  end

  def render
    builder
      .add_line("#{parameters[0].value}:: @ Dbr2-output")
      .yield_children
      .add_line('end') unless children.last.command == 'return' 

    subscripts.each { |subscript|
      
    }
  end
end