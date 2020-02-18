def create_line(hash)
  OpenStruct.new({
    parameters: Parameter::List.new(hash.map { |name, value|
      type = 
        case value
        when String
          :string
        when Numeric
          :number
        end
      
      Parameter::Type.create(type, value)
    }),
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
        world: 'world',
        hello: 'world',
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
        name: 1,
      })

      expect {
        command.new(line, nil, nil).enforce
      }.to raise_error(WrongType)
    end

    it 'works the rest of the time' do
      command = Class.new(Command) do
        def expect_params(p)
          p.name :string
        end
      end

      line = create_line({
        name: 'dakota',
      })

      expect {
        command.new(line, nil, nil).enforce
      }.not_to raise_error
    end
  end

  describe 'binding to names' do
    it 'binds based on position' do
      command = Class.new(Command) do
        def expect_params(p)
          p.name :string
        end
      end

      line = create_line({
        name: 'dakota',
      })

      command.new(line, nil, nil).enforce
      expect(line.parameters.name).to eq('dakota')
    end

    it 'can bind multiple' do
      command = Class.new(Command) do
        def expect_params(p)
          p.hello :string
          p.world :string
        end
      end

      line = create_line({
        hello: 'hello',
        world: 'world',
      })
      p line.parameters.collect(&:class)

      command.new(line, nil, nil).enforce
      expect(line.parameters.hello).to eq('hello')
      expect(line.parameters.world).to eq('world')
    end
  end
end