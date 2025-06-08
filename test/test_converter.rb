# frozen_string_literal: true

require "test_helper"
require "be_let_it_be/analyzer"
require "be_let_it_be/converter"

class TestConverter < Minitest::Test
  def test_try_converting_single_let
    source = <<~RUBY
      RSpec.describe "Test" do
        let(:value) { 42 }
        
        it "works" do
          expect(value).to eq(42)
        end
      end
    RUBY

    Tempfile.create("test_spec.rb") do |temp_file|
      File.write(temp_file, source)

      analyzer = BeLetItBe::Analyzer.new(temp_file)
      lets = analyzer.find_lets
      converter = BeLetItBe::Converter.new(temp_file)

      converter.try_conversion_single_let(lets.first, temp_file, -> { true })

      result = File.read(temp_file)
      assert_includes result, "let_it_be(:value)"
      refute_includes result, "let(:value)"
    end
  end

  def test_apply_multiple_conversions
    source = <<~RUBY
      RSpec.describe "Test" do
        let(:first) { 1 }
        let!(:second) { 2 }
        let(:third) { 3 }
      end
    RUBY

    Tempfile.create("test_spec.rb") do |temp_file|
      File.write(temp_file, source)

      analyzer = BeLetItBe::Analyzer.new(temp_file)
      lets = analyzer.find_lets
      converter = BeLetItBe::Converter.new(temp_file)

      until lets.empty?
        converter.try_conversion_single_let(lets.first, temp_file, -> { true })

        analyzer = BeLetItBe::Analyzer.new(temp_file)
        lets = analyzer.find_lets
        converter = BeLetItBe::Converter.new(temp_file)
      end

      result = File.read(temp_file)
      assert_includes result, "let_it_be(:first)"
      assert_includes result, "let_it_be(:second)" # Should remain unchanged
      assert_includes result, "let_it_be(:third)"
    end
  end
end
