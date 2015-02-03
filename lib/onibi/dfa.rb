require 'set' unless defined?(Set)

module Onibi
  # Represents deterministic finite automaton (DFA).
  # @!visibility private
  class DFA
    # @!visibility private
    attr_accessor :start, :accepts, :transition

    # Constructs an instance of Onibi::DFA.
    # @param start [Integer]
    # @param accepts [Set]
    # @yield The block is treated as transition function.
    # @yieldparam [Integer] current state
    # @yieldparam [String] char
    # @yieldreturn [Integer] next state
    # @!visibility private
    def initialize(start, accepts, &transition)
      @start = start
      @accepts = accepts
      @transition = transition
    end

    # Returns true if final state can be accepted.
    # @param input [String] 
    # @!visibility private
    def accept?(input)
      current = @start
      input.each_char { |char| current = @transition.call(current, char) }
      not (current & accepts).empty?
    end
  end
end
