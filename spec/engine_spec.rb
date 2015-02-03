require 'spec_helper'

RSpec.describe Onibi::Engine do
  describe "#match?" do
    describe "|" do
      subject { Onibi::Engine.new("asdf|ghjk") }

      context "with valid string" do
        it { should be_match("asdf") }
        it { should be_match("ghjk") }
      end

      context "with invalid string" do
        it { should_not be_match("namusyaka") }
        it { should_not be_match("padrino framework") }
      end
    end

    describe "*" do
      subject { Onibi::Engine.new("asdf*") }

      context "with valid string" do
        it { should be_match("asd") }
        it { should be_match("asdf") }
        it { should be_match("asdfffff") }
      end

      context "with invalid string" do
        it { should_not be_match("namusyaka") }
        it { should_not be_match("asdddd") }
      end
    end

    describe "?" do
      subject { Onibi::Engine.new("asdf?") }

      context "with valid string" do
        it { should be_match("asd") }
        it { should be_match("asdf") }
      end

      context "with invalid string" do
        it { should_not be_match("asdff") }
        it { should_not be_match("hoge") }
      end
    end

    describe "+" do
      subject { Onibi::Engine.new("asdf+") }
    end

    describe "(|)*" do
      subject { Onibi::Engine.new("(asdf|ghjk)*") }

      context "" do
        it { should be_match("") }
        it { should be_match("asdf") }
        it { should be_match("asdfghjk") }
      end

      context "with invalid string" do
        it { should_not be_match("asdfgh") }
        it { should_not be_match("asdfas") }
      end
    end
  end

  describe "===" do
    subject { Onibi::Engine }
    it { expect(subject.instance_method(:===)).to eq(subject.instance_method(:match?)) }
  end
end
