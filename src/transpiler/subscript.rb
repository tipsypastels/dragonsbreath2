class Subscript < Struct.new(:name, :type, :texts, :source, :source_parent)
  def descendant_of?(line)
    source.descendant_of?(line)
  end
end