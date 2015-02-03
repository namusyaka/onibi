module Onibi
  TokenError          ||= Class.new(StandardError)
  TerminalSymbolError ||= Class.new(ArgumentError)
  SyntaxError         ||= Class.new(StandardError)
  ConvertError        ||= Class.new(ArgumentError)
end
