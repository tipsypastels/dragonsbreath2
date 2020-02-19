RSpec::Matchers.define :output_to do |expected|
  match do |actual|
    @actual_result = Script::Types::TopLevel.execute(Parser.new(actual).parse)
    @actual_result.to_s == expected.to_s
  end

  failure_message do |actual|
    <<~MESSAGE
      expected: #{expected}
      got:      #{@actual_result}
    MESSAGE
  end
end

describe "Commands" do
  describe 'lock' do
    it 'works' do
      expect('lock').to output_to('lock')
    end
  end
end