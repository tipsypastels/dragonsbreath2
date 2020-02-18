RSpec::Matchers.define :transpile_to do |expected|
  match do |actual|
    @actual_result = Script::Types::TopLevel.execute(actual)
    @actual_result.to_s == expected.to_s
  end

  failure_message do |actual|
    <<~MESSAGE
      expected: #{expected}
      got:      #{@actual_result}
    MESSAGE
  end
end

def simple_script(command, parameters = [])
  [Line.new(
    0, 
    'script', 
    Parameter::List.new([Parameter::Type.create(:token, 'MyScript')]), 
    0, 
    children: [
      Line.new(
        1,
        command,
        Parameter::List.new(
          parameters.map { |type, value| 
            Parameter::Type.create(type, value)
          },
        ),
        1,
      ),
    ],
  )]
end

RSpec.describe 'Commands' do
  describe 'simple commands' do
    describe 'lock' do
      it 'works' do
        expect(simple_script('lock')).to transpile_to <<~OUTPUT
          script TestScript
            lock
            end
        OUTPUT
      end
    end
  end
end