class Parameter::List
  include Enumerable

  def initialize(params)
    @params = params.compact
  end

  delegate :length, :each, :empty?, to: :params

  def to_a
    @params.map(&:to_h)
  end
  alias to_ary to_a

  def bind_named_parameter(name, index)
    define_singleton_method(name) { params[index] }
  end
  
  private

  attr_reader :params
end