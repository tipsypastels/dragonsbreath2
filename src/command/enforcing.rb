module Command::Enforcing
  def enforce
    expecter = Transpiler::Parameters::Expecter
      .new(self)

    expect_params(expecter)
    expecter.enforce(parameters)
  end

  def expect_params(p)
  end
end