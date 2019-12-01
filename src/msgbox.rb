module Msgbox
  DEFAULT = 'MSGBOX_DEFAULT'

  mattr_accessor :current
  self.current = DEFAULT

  def self.change(value)
    begin
      self.current = value
      yield
    ensure
      self.current = DEFAULT
    end
  end
end