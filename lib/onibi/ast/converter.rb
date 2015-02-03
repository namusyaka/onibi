require 'onibi/errors'

module Onibi
  module AST
    # This class is for converting meta characters into minimal representation.
    # @!visibility private
    class Converter
      # @!visibility private
      attr_reader :buffer

      # Constructs an instance of Onibi::AST::Converter.
      # @param input [String]
      def initialize(input)
        @input  = input
        @buffer = []
      end

      # Converts into minimal representation recursively.
      # @return [String] converted string
      def convert
        result = catch(:restart) do
          @input.each_char.with_index do |char, offset|
            dispatch(char, @input[offset - 1], offset)
          end
          @buffer.join
        end
        result || convert
      end

      # Returns all registered meta characters.
      # @return [Array]
      def self.meta_characters
        @meta_characters ||= []
      end

      # Returns true if char is added as a meta character.
      # @return [Boolean]
      # @!visibility private
      def meta_character?(char)
        Converter.meta_characters.include?(char)
      end

      # Dispatches correct method to the character.
      # @param char [String]
      # @param prev_char [String]
      # @param offset [Integer]
      # @!visibility private
      def dispatch(char, prev_char, offset)
        return (@buffer << char) unless prev_char != ?\\ && meta_character?(char)
        name = "rule %p with %p" % [char, prev_char]
        name = "rule %p" % char unless respond_to?(name)
        method(name).arity != 0 ? send(name, offset) : send(name)
      end

      # Prepares environment for defining rules.
      # @param char [String]
      # @yield Evaluates the block by using Object#instance_eval.
      def self.rule(char, &block)
        @char = char
        instance_eval(&block)
      end

      # Defines a method as default rule for converting the character.
      # This should be used inside a block passed in Onibi::AST::Converter.rule.
      # @yield The block is passed to define_method.
      # @see {Onibi::AST::Converter.rule}
      def self.default(&block)
        define_method("rule %p" % @char, &block)
      end

      # Defines a method as atypical rule for converting the character.
      # This should be used inside a block passed in Onibi::AST::Converter.rule.
      # @param prev_char [String]
      # @yield The block is passed to define_method.
      # @see {Onibi::AST::Converter.rule}
      def self.before(prev_char, &block)
        define_method("rule %p with %p" % [@char, prev_char], &block)
      end

      # Adds char as a meta character and returns itself.
      # @param char [String]
      # @return [String]
      def self.on(char)
        meta_characters << char
        char
      end

      # Scan target string while taking escape character into consideration
      # and returns the position of passed character.
      # @raise [Onibi::ConvertError] Raised if corresponding char can not be found.
      # @return [Integer]
      def scan(char, offset)
        pos = @input.index(char, offset)
        fail ConvertError, 'Corresponding %p can not be found' % char unless pos
        @input[pos - 1] == ?\\ ? scan(char, pos) : pos
      end

      # Defines a rule about "?".
      # Expectation:
      #   asdf?   #=> asd(f|)
      #   (asdf)? #=> (asdf|)
      rule on(??) do
        # If previous character is not ")", makes a group
        # including the char and empty, and appends it to buffer. 
        default { buffer << "(%s|)" % buffer.pop }
        # If previous character is ")", appends | just before the previous char.
        before(?)) { |offset| buffer[offset - 2] << ?| }
      end

      # Defines a rule about "+".
      # Expectation:
      #   asdf+   #=> asdff*
      #   (asdf)+ #=> (asdf)(asdf)*
      rule on(?+) do
        # If previous character is not ")", doubles the character and appends it.
        default { buffer << "%s*" % (buffer.pop * 2) }
        # If previous character is ")", doubles the group and appends it.
        before(?)) do |offset|
          current, stack = offset - 2, []
          until buffer[current] == ?( && !stack.pop
            stack << 1 if buffer[current] == ?)
            current -= 1
          end
          buffer << (buffer.slice(current..offset) << ?*).join
        end
      end

      # Defines a rule about "[]".
      # Expectation:
      #   [01] #=> (0|1)
      rule on(?[) do
        default do |offset|
          square_brackets = @input.slice(offset..scan(?], offset))
          elements = square_brackets.split(//)[1..-2]
          elements.map! { |char| meta_character?(char) ? ?\\ << char : char }
          @input.gsub!(square_brackets, "(%s)" % (elements * ?|))
          throw :restart
        end
      end

      private :scan
    end
  end
end
