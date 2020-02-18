module Command::Table
  extend ActiveSupport::Concern

  ENTRIES = {
    script: Command::Builtins::Script,
    lock: Command::Builtins::Lock,
  }.with_indifferent_access

  class_methods do
    def table
      Command::Table::ENTRIES
    end

    def [](name)
      table[name]
    end
  end
end