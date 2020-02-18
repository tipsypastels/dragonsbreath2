IMPORTANT_KEYS = %i|command parameters children|

def to_testable_hash(line)
  line.to_h.delete_if { |key| !key.in? IMPORTANT_KEYS }
           .tap { |hash|
             hash[:children]&.map!(&method(:to_testable_hash))
           }
end

RSpec::Matchers.define :parse_to do |expected|
  match do |actual|
    @actual_result = Parser.new(actual).parse
      .map(&method(:to_testable_hash))

    @actual_result == expected
  end

  failure_message do |actual|
    <<~MESSAGE
      expected: #{JSON.pretty_generate expected}
      got:      #{JSON.pretty_generate @actual_result}
    MESSAGE
  end
end

RSpec.describe Parser do
  describe 'syntax' do
    it 'parses a single command' do
      expect('x 1').to parse_to [{
        command: 'x',
        parameters: [{ type: :number, value: 1 }],
      }]
    end

    it 'parses two commands with the same indent' do
      expect("x 1\ny 2").to parse_to [
        {
          command: 'x',
          parameters: [{ type: :number, value: 1 }]
        },
        {
          command: 'y',
          parameters: [{ type: :number, value: 2 }],
        },
      ]
    end

    it 'parses a two-level indent' do
      expect("x 1\n  y 2").to parse_to [{
        command: 'x',
        parameters: [{ type: :number, value: 1 }],
        children: [{
          command: 'y',
          parameters: [{ type: :number, value: 2 }],
        }],
      }]
    end

    it 'parses a three-level indent' do
      expect("a\n  b\n    c").to parse_to [{
        command: 'a',
        children: [{
          command: 'b',
          children: [{ command: 'c' }],
        }],
      }]
    end

    it 'parses multiple layers with lots of children' do
      program = <<~CODE
        if a == 1
          say "hello world"
        else
          playfanfare SOME_MUSIC
          givemon A_DUCK
          say "Got a duck"
      CODE

      expect(program).to parse_to [
        COND_BUNDLE[{
          command: 'if',
          parameters: [{
            type: :eq,
            value: {
              left: { type: :token, value: 'a' },
              right: { type: :number, value: 1 },
            },
          }],
          children: [TEXT_BUNDLE[{
            command: 'say',
            parameters: [{
              type: :string, value: 'hello world',
            }],
          }]],
        }, {
          command: 'else',
          children: [
            {
              command: 'playfanfare',
              parameters: [{ 
                type: :constant,
                value: 'SOME_MUSIC', 
              }],
            },
            {
              command: 'givemon',
              parameters: [{
                type: :constant,
                value: 'A_DUCK',
              }],
            },
            TEXT_BUNDLE[{
              command: 'say',
              parameters: [{
                type: :string,
                value: 'Got a duck'
              }],
            }],
          ],
        }]
      ]
    end

    it 'ignores comments' do
      expect('x # hello\n# comment line').to parse_to [{
        command: 'x',
      }]
    end

    it 'converts floating quotes to say' do
      expect('"text"').to parse_to [TEXT_BUNDLE[{
        command: 'say',
        parameters: [{ type: :string, value: 'text' }],
      }]]
    end
  end

  describe 'parameters' do
    it 'parses commands without parameters' do
      expect('x').to parse_to [{
        command: 'x'
      }]
    end

    it 'parses commands with one' do
      expect('x 1').to parse_to [{
        command: 'x',
        parameters: [{ type: :number, value: 1 }],
      }]
    end

    it 'parses commands with many' do
      expect('x 1, 2, 3').to parse_to [{
        command: 'x',
        parameters: [
          { type: :number, value: 1 },
          { type: :number, value: 2 },
          { type: :number, value: 3 },
        ],
      }]
    end

    it 'doesnt break params on commas inside strings' do
      expect('x "a, b", "c, d"').to parse_to [{
        command: 'x',
        parameters: [
          { type: :string, value: 'a, b' },
          { type: :string, value: 'c, d' },
        ],
      }]
    end
  end

  describe 'bundling' do
    it 'bundles one say command' do
      expect("say 1").to parse_to [
        TEXT_BUNDLE[{
          command: 'say',
          parameters: [{ type: :number, value: 1 }]
        }],
      ]
    end

    it 'bundles two say commands' do
      expect("say 1\nsay 2").to parse_to [
        TEXT_BUNDLE[
          { 
            command: 'say',
            parameters: [{ type: :number, value: 1 }], 
          },
          { 
            command: 'say',
            parameters: [{ type: :number, value: 2 }], 
          },
        ]
      ]
    end

    it 'bundles three say commands' do
      expect("say 1\nsay 2\nsay 3").to parse_to [
        TEXT_BUNDLE[
          { 
            command: 'say',
            parameters: [{ type: :number, value: 1 }], 
          },
          { 
            command: 'say',
            parameters: [{ type: :number, value: 2 }], 
          },
          { 
            command: 'say',
            parameters: [{ type: :number, value: 3 }], 
          },
        ]
      ]
    end

    it 'doesnt bundle across indent changes' do
      expect("say 1\n  say 2").to parse_to [
        TEXT_BUNDLE[{
          command: 'say',
          parameters: [{ type: :number, value: 1 }],
          children: [
            TEXT_BUNDLE[{
              command: 'say',
              parameters: [{ type: :number, value: 2 }],
            }],
          ],
        }],
      ]
    end

    it 'doent bundle if the parameter# is different' do
      expect("say 1, 2\nsay 3").to parse_to [
        TEXT_BUNDLE[{
          command: 'say',
          parameters: [
            { type: :number, value: 1 },
            { type: :number, value: 2 },
          ]
        }],
        TEXT_BUNDLE[{
          command: 'say',
          parameters: [{
            type: :number, value: 3,
          }]
        }]
      ]
    end

    it 'doent bundle if only one has params' do
      expect("say 1\nsay").to parse_to [
        TEXT_BUNDLE[{
          command: 'say',
          parameters: [
            { type: :number, value: 1 },
          ],
        }],
        TEXT_BUNDLE[{
          command: 'say',
        }],
      ]
    end

    it 'bundles two children of a parent' do
      expect("x\n  say 1\n  say 2").to parse_to [{
        command: 'x',
        children: [
          TEXT_BUNDLE[{
            command: 'say',
            parameters: [{
              type: :number,
              value: 1,
            }]
          }, {
            command: 'say',
            parameters: [{
              type: :number,
              value: 2,
            }],
          }],
        ],
      }]
    end
  end
end

TEXT_BUNDLE = ->(*cmd) {
  {
    command: 'text_bundle',
    children: cmd,
  }
}

COND_BUNDLE = ->(*cmd) {
  {
    command: 'cond_bundle',
    children: cmd,
  }
}