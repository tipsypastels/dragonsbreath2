module Script::Parser
  extend ActiveSupport::Concern

  class_methods do
    def parse(*a, **b)
      new(*a, **b).parse
    end
  end

  def parse
    
  end

  private

  def beginning
    "#{name}#{scope_to_engine} @ Dbr-output"
  end

  def ending
  end
end