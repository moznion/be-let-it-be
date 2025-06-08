# frozen_string_literal: true

require "test_prof/recipes/rspec/before_all"
require "test_prof/recipes/rspec/let_it_be"

class TestProfDummyAdapter
  def begin_transaction
  end

  def rollback_transaction
  end

  def commit_transaction
  end
end

TestProf::BeforeAll.adapter = TestProfDummyAdapter.new

RSpec.describe "Sample" do
  let!(:bang_value) { "important" }
  let(:computed_value) { simple_value * 2 }
  let(:simple_value) { 42 }

  context "when testing" do
    let(:context_value) { "context specific" }

    it "uses simple_value" do
      expect(simple_value).to eq(42)
    end

    it "uses bang_value" do
      expect(bang_value).to eq("important")
    end

    it "uses computed_value" do
      expect(computed_value).to eq(84)
    end

    it "uses context_value" do
      expect(context_value).to eq("context specific")
    end
  end

  context "when value is mutable" do
    let(:mutable_array) { [] }

    it "can modify the array" do
      mutable_array << 1
      expect(mutable_array).to eq([1])
    end

    it "starts fresh in each test" do
      expect(mutable_array).to eq([])
    end
  end
end
