require 'onibi/ast/lexer'
require 'onibi/nfa'
require 'onibi/errors'

module Onibi
  module AST
    # Parses the input and converts into nondeterministic finite automaton.
    # @!visibility private
    class Parser
      # Defines for use in unary operator classes.
      # @!visibility private
      Unary  = Struct.new(:operand)
      # Defines for use in binary operator classes.
      # @!visibility private
      Binary = Struct.new(:left, :right)

      # Represents the minimum character.
      # @!visibility private
      class Character < Unary
        def assemble(context)
          fragment = NFA::Fragment.new
          one_state = context.new_state
          two_state = context.new_state
          fragment.connect(one_state, operand, two_state)
          fragment.start = one_state
          fragment.accepts = Set.new([two_state])
          fragment
        end
      end

      # Represents the union.
      # @!visibility private
      class Union < Binary
        def assemble(context)
          one_fragment = left.assemble(context)
          two_fragment = right.assemble(context)
          fragment = one_fragment | two_fragment
          state = context.new_state
          fragment.connect(state, "", one_fragment.start)
          fragment.connect(state, "", two_fragment.start)
          fragment.start = state
          fragment.accepts = one_fragment.accepts | two_fragment.accepts
          fragment
        end
      end

      # Represents the concatination.
      # @!visibility private
      class Concat < Binary
        def assemble(context)
          one_fragment = left.assemble(context)
          two_fragment = right.assemble(context)
          fragment = one_fragment | two_fragment
          one_fragment.accepts.each do |state|
            fragment.connect(state, "", two_fragment.start)
          end
          fragment.start   = one_fragment.start
          fragment.accepts = two_fragment.accepts
          fragment
        end
      end

      # Represents the repetition.
      # @!visibility private
      class Star < Unary
        def assemble(context)
          original_fragment = operand.assemble(context)
          fragment = original_fragment.new_skelton
          original_fragment.accepts.each do |state|
            fragment.connect(state, "", original_fragment.start)
          end
          state = context.new_state
          fragment.connect(state, "", original_fragment.start)
          fragment.start = state
          fragment.accepts = original_fragment.accepts | Set.new([state])
          fragment
        end
      end

      # This is for using state management.
      # @!visibility private
      class Context
        def initialize
          @count = 0
        end

        def new_state
          @count += 1
        end
      end

      # Defines a method as a rule for parsing tokens.
      # @param terminal_symbol [String]
      # @yield The block is defined as a method like "rule \"#{terminal_symbol}\"".
      # @!visibility private
      def self.rule(terminal_symbol, &block)
        define_method("rule %p" % terminal_symbol, &block)
      end

      # Constructs an instance of Onibi::AST::Parser.
      # @param input [String]
      # @!visibility private
      def initialize(input)
        @lexer = Lexer.new(input)
        @current_token = nil
        forward
      end

      # Checkes the type with current token's one.
      # @param type [Integer] 
      # @raise [Onibi::SyntaxError] Raised if current token isn't same with the type.
      # @!visibility private
      def match(type)
        fail SyntaxError, "Syntax Error (%p)" % type unless @current_token.type == type
        forward
      end

      # Forwards one character via {Onibi::AST::Lexer#scan}.
      # @!visibility private
      def forward
        @current_token = @lexer.scan
      end

      # Executes a defined rule.
      # @param terminal_symbol [String]
      # @raise Raised if terminal_symbol isn't registered as a rule.
      def exec(terminal_symbol)
        method_name = "rule %p" % terminal_symbol
        unless respond_to?(method_name)
          fail TerminalSymbolError, "unknown terminal symbol (%p)" % terminal_symbol
        end
        send(method_name)
      end

      # Converts into nondeterministic finite automaton.
      def to_nfa
        exec(:expression)
      end

      # factor -> '(' subexpr ')' | Character
      rule(:factor) do
        if @current_token.left?
          match(Token::Left.type)
          node = exec(:subexpr)
          match(Token::Right.type)
          node
        else
          node = Character.new(@current_token.value)
          match(Token::Character.type)
          node
        end
      end

      # star -> factor '*' | factor
      rule(:star) do
        node = exec(:factor)
        return node unless @current_token.star?
        match(Token::Star.type)
        Star.new(node)
      end

      # seq -> subseq | ''
      rule(:seq) do
        return exec(:subseq) if @current_token.left? || @current_token.character?
        Character.new("")
      end

      # subseq -> star subseq | star
      rule(:subseq) do
        node = exec(:star)
        return node unless @current_token.left? || @current_token.character?
        Concat.new(node, exec(:subseq))
      end

      # subexpr -> seq '|' subexpr | seq
      rule(:subexpr) do
        node = exec(:seq)
        return node unless @current_token.union?
        match(Token::Union.type)
        Union.new(node, exec(:subexpr))
      end

      # expression -> subexpr EOF
      rule(:expression) do
        node = exec(:subexpr)
        match(Token::Eof.type)
        context = Context.new
        node.assemble(context).build
      end
    end
  end
end
