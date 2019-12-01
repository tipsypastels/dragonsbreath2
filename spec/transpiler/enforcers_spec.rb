def create_line(hash)
  OpenStruct.new({
    parameters: hash.map { |value, type| 
      { type: type, value: value }
    },
  })
end

TooMany = DbrError::Enforcer::Parameters::TooMany
Missing = DbrError::Enforcer::Parameters::Missing
WrongType = DbrError::Enforcer::Parameters::WrongType

RSpec.describe 'Enforcers' do
  describe 'parameter enforcer' do
    it 'fails when there are too many or few' do
      command = Class.new(Command) do
        def expect_params(p)
          p.world :string
        end
      end

      line = create_line({
        world: :string,
        hello: :string,
      })

      expect {
        command.new(line, nil, nil).enforce
      }.to raise_error(TooMany)

      line = create_line({})

      expect {
        command.new(line, nil, nil).enforce
      }.to raise_error(Missing)
    end

    it 'fails when the type is wrong' do
      command = Class.new(Command) do
        def expect_params(p)
          p.name :string
        end
      end

      line = create_line({
        name: :number,
      })

      expect {
        command.new(line, nil, nil).enforce
      }.to raise_error(WrongType)
    end
  end
end