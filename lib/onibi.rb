require "onibi/version"
require "onibi/engine"

module Onibi
  # see {Onibi::Engine}
  def self.new(expression)
    Engine.new(expression)
  end
end
