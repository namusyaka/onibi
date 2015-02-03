require 'onibi/ast/token'
require 'onibi/ast/converter'
require 'onibi/errors'

module Onibi
  module AST
    # Onibi::AST::Lexer is for lexical analysis.
    # @!visibility private
    class Lexer
      # Constructs an instance of Onibi::AST::Lexer.
      # @param input [String]
      def initialize(input)
        input = Converter.new(input).convert
        @input = input.split(//u)
      end
  
      # Scans a string character one by one.
      # @return [Onibi::AST::Token] Returns a class inherited from {Onibi::AST::Token}.
      # @return [Onibi::AST::Token::Eof] Returns if the input is empty.
      def scan
        return Token::Eof.new(nil) if @input.empty?
        char = @input.shift
        method_name = "scan %p" % char
        respond_to?(method_name) ? send(method_name, char) : default_token(char)
      end
  
      # Returns a class inherited from {Onibi::AST::Token} if available
      # @raise [Onibi::TokenError] Raised if name is not registered as a token.
      # @return [Onibi::AST::Token]
      def token(name, char)
        fail TokenError, '%p is not registered' % name unless Token.exist?(name)
        Token.const_get(name.to_s.capitalize).new(char)
      end
  
      # Defines a rule for use in all characters except some meta characters.
      # @yield The block is defined as #default_token method.
      def self.default_token(&block)
        define_method(:default_token, &block)
      end
  
      # Defines a rule for meta characters.
      # @yield The block is defined as a method like "scan \"#{char}\"".
      def self.on(char, &block)
        define_method("scan %p" % char, &block)
      end
  
      default_token { |char| token(:character, char) }
  
      on(?\\) { |char| token(:character, @input.shift) }
      on(?|)  { |char| token(:union, char) }
      on(?()  { |char| token(:left, char) }
      on(?))  { |char| token(:right, char) }
      on(?*)  { |char| token(:star, char) }
    end
  end
end
