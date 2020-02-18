RSpec::Matchers.define :be_param do |type, value = nil|
  expected = { type: type }
  expected[:value] = value if value

  match do |actual|
    @actual_result = Parameter::Parser.new(actual)
      .parse
      .to_h

    @actual_result.to_s == expected.to_s
  end

  failure_message do |actual|
    <<~MESSAGE
      expected: #{expected}
      got:      #{@actual_result}
    MESSAGE
  end
end

RSpec.describe Parameter::Parser do
  it 'parses the keyword it' do
    expect('it').to be_param :it
  end

  context 'scopes' do
    it 'parses global' do
      expect('(global)').to be_param :scope, :global
    end

    it 'parses local' do
      expect('(local)').to be_param :scope, :local
    end
  end

  context 'numbers' do
    it 'parses floats' do
      expect('3.14').to be_param :number, 3.14
    end
    
    it 'parses integers' do
      expect('1').to be_param :number, 1
    end

    it 'parses multi digit numbers' do
      expect('23').to be_param :number, 23
    end

    it 'parses leading decimals' do
      expect('.3').to be_param :number, 0.3
    end

    it 'parses trailing decimals' do
      expect('2.').to be_param :number, 2
    end
  end

  context 'constants' do
    it 'parses constants' do
      expect('HELLO_WORLD').to be_param :constant, 'HELLO_WORLD'
    end

    it 'parses constants with x' do
      expect('VAR_0x400').to be_param :constant, 'VAR_0x400'
    end
  end

  it 'parses tokens' do
    expect('hello').to be_param :token, 'hello'
  end

  context 'comparisons' do
    %i|eq lt gt le ge|.each do |comp|
      it "parses #{comp}" do
        expect("a #{comp} b").to be_param comp, {
          left: { type: :token, value: 'a' },
          right: { type: :token, value: 'b' },
        }
      end
    end

    it 'parses flags' do
      %i|flag set|.each do |flag_alias|
        expect("#{flag_alias}? CONSTANT").to be_param :flag, {
          check: { type: :constant, value: 'CONSTANT' },
          inverse: false,
        }
      end

      expect('unset? CONSTANT').to be_param :flag, {
        check: { type: :constant, value: 'CONSTANT' },
        inverse: true,
      }
    end
  end
end