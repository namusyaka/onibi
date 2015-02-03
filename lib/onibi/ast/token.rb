module Onibi
  module AST
    # Onibi::AST::Token is for inheriting to meta character classes.
    # And registers primary meta character token classes.
    # @!visibility private
    class Token
      # @!visibility private
      attr_reader :value, :type

      # Constructs an instance of Onibi::AST::Token.
      # @param char [String]
      # @!visibility private
      def initialize(value)
        @value = value
        @type  = self.class.type
      end

      # Returns type id of the class.
      # @return [Integer] type id of the class.
      # @!visibility private
      def self.type
        @type
      end

      # Registers new character token class.
      # @param token [String, Symbol]
      # @!visibility private
      def self.register(token)
        name = token.capitalize
        unless const_defined?(name)
          klass = const_set(name, Class.new(Token))
          type_id = tokens.length
          klass.instance_variable_set(:@type, type_id)
          define_method("#{token}?"){ @type == type_id }
          tokens << token
        end
      end

      # Returns true if the token is already registered.
      # @param token [String, Symbol]
      # @return [Boolean]
      # @!visibility private 
      def self.exist?(token)
        const_defined?(token.to_s.capitalize)
      end

      # Returns all registered tokens.
      # @return [Array<String, Symbol>]
      # @!visibility private 
      def self.tokens
        @tokens ||= []
      end

      register :character
      register :union
      register :star
      register :left
      register :right
      register :eof
    end
  end
end
