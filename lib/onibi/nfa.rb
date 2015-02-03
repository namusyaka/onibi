require 'onibi/dfa'

module Onibi
  # Represents non-deterministic finite automaton (NFA).
  # @!visibility private
  class NFA
    # @!visibility private
    attr_accessor :start, :accepts, :transition

    # Constructs an instance of Onibi::NFA.
    # @param start [Set]
    # @param accepts [Set]
    # @yield The block is treated as transition function.
    # @yieldparam [Set] current states
    # @yieldparam [String] char or empty
    # @yieldreturn [Set] Set of next states
    # @!visibility private
    def initialize(start, accepts, &transition)
      @start = start
      @accepts = accepts
      @transition = transition
    end

    # Creates new set considered ε-moves from state set.
    # @param set [Set]
    # @!visibility private
    def epsilon_expand(set)
      queue = set.to_a
      done  = Set.new
      until queue.empty?
        state = queue.pop
        nexts = @transition.call(state, "")
        done.add(state)
        nexts.each do |next_state|
          queue << next_state unless done.include?(next_state)
        end
      end
      Set.new(done).freeze
    end

    # Returns true if final state can be accepted.
    # @param input [String] 
    # @!visibility private
    def accept?(input)
      current = @start
      input.each_char { |char| current = @transition.call(current, char) }
      accepts.include?(current)
    end

    # Converts into deterministic finite automaton.
    # @return [Onibi::DFA]
    def to_dfa
      DFA.new(epsilon_expand(Set.new([@start]).freeze), accepts) do |set, alpha|
        ret = Set.new
        set.each { |element| ret |= @transition.call(element, alpha) }
        epsilon_expand(Set.new(ret).freeze)
      end
    end

    # The fragment is for use in {Onibi::AST::Parser}.
    # @!visibility private
    class Fragment
      attr_accessor :start, :accepts, :map

      def initialize
        @start = nil
        @accepts = nil
        @map = {}
      end

      def connect(from, char, to)
        slot = (@map[[from, char]] ||= Set.new)
        slot.add(to)
      end

      def new_skelton
        new_fragment = Fragment.new
        new_fragment_map = {}
        @map.each_pair { |k,v| new_fragment_map[k] = v }
        new_fragment.map = new_fragment_map
        new_fragment
      end

      def |(fragment)
        new_fragment = new_skelton
        fragment.map.each_pair { |k, v| new_fragment.map[k] = v.dup }
        new_fragment
      end

      def build
        copied_map = @map.dup
        NFA.new(@start, @accepts) do |state, char|
          Set.new(copied_map[[state, char]]).freeze
        end
      end
    end
  end
end
