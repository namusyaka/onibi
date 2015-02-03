require 'spec_helper'

RSpec.describe Onibi::AST::Token do
  describe ".register" do
    subject { Onibi::AST::Token::Foo }
    before(:all) { Onibi::AST::Token.register(:foo); Onibi::AST::Token.register(:any) }
    let(:foo) { subject.new("token") }
    it { expect(foo.value).to eq("token") }
    it { expect(foo.type).to eq(subject.type) }
    it { expect(foo.foo?).to be_truthy }
    it { expect(foo.any?).to be_falsey }
    it { expect(Onibi::AST::Token::Foo.type).to eq(6) }
    it { expect(Onibi::AST::Token::Any.type).to eq(7) }
  end

  describe ".exist?" do
    before(:all){ Onibi::AST::Token.register(:bar) }
    it { expect(Onibi::AST::Token.exist?(:bar)).to be_truthy }
    it { expect(Onibi::AST::Token.exist?(:baz)).to be_falsey }
  end
end
