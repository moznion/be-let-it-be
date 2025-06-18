# frozen_string_literal: true

RSpec.describe "NoConvertible" do
  let(:mutable_value) { [] }

  it "uses mutable value" do
    mutable_value << 1
    expect(mutable_value).to eq([1])
  end
end
