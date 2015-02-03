require 'spec_helper'

RSpec.describe Onibi::AST::Converter do
  describe "converting" do
    subject { described_class.new(expr).convert }

    describe ?? do
      context "with default" do
        let(:expr) { "asdf?" }
        it { should eq("asd(f|)") }
      end

      context "')' is a previous char" do
        let(:expr) { "(asdf)?" }
        it { should eq("(asdf|)") }
      end

      context "')' is a previous char, and includes nested brackets" do
        let(:expr) { "(as(d)f)?" }
        it { should eq("(as(d)f|)") }
      end
    end

    describe ?+ do
      context "with default" do
        let(:expr) { "asdf+" }
        it { should eq("asdff*") }
      end

      context "')' is a previous char" do
        let(:expr) { "(asdf)+" }
        it { should eq("(asdf)(asdf)*") }
      end

      context "')' is a previous char, and includes nested brackets" do
        let(:expr) { "(as(d)f)+" }
        it { should eq("(as(d)f)(as(d)f)*") }
      end
    end

    describe ?. do
      context "with default" do
        let(:expr) { ".*" }
        it { should eq("(#{described_class.single_chars * ?|})*") }
      end
    end

    describe ?[ do
      context "with default" do
        let(:expr) { "[012]+?" }
        it { should eq("(0|1|2)((0|1|2)*|)") }
      end

      context "with invalid chars" do
        let(:expr) { "[123" }
        it { expect { subject }.to raise_error(Onibi::ConvertError, 'Corresponding "]" can not be found') }
      end
    end
  end
end
