class Script::Manager
  attr_reader :scripts

  def initialize
    @scripts = []
  end

  def push(script)
    unless script.is_a? Script
      raise DbrError::Scripts::WrongTopLevel
    end

    scripts.push(script)
  end
end