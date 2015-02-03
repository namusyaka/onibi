require 'onibi/ast/parser'

module Onibi
  # Engine is the end point of Onibi.
  # This only provides two matching methods.
  class Engine
    # Constructs an instance of Onibi::Engine.
    # @param expression [String]
    def initialize(expression)
      parser = AST::Parser.new(expression)
      @dfa = parser.to_nfa.to_dfa
    end

    # Returns true if the string is matched with expression.
    # @param string [String]
    def match?(string)
      @dfa.accept?(string)
    end
    alias === match?
  end
end
