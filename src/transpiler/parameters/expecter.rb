class Transpiler::Parameters::Expecter
  def initialize(command)
    @command = command
    @list = []
  end

  attr_reader :command, :list
  delegate :each, :zip, :length, to: :list

  def method_missing(name, *types, optional: false)
    unless types
      raise "Type declaration missing for parameter #{name} in #{command}"
    end

    list.push(OpenStruct.new({
      name: name,
      types: types,
      optional: optional,
    }))
  end

  def enforce(actual)
    Transpiler::Parameters::Enforcer.new(
      command, 
      self, 
      actual
    ).enforce
  end

  # this doesn't actually do anything, an empty block will signify no parameters because nothing will get pushed to the array. however, that's not clear, so we do this pointless dsl
  def none
  end
end