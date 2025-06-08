# frozen_string_literal: true

require "test_helper"
require "be_let_it_be/analyzer"

class TestAnalyzer < Minitest::Test
  def test_find_lets_in_sample_file
    analyzer = BeLetItBe::Analyzer.new(fixture_path("sample_spec.rb"))
    lets = analyzer.find_lets

    assert_equal 5, lets.size

    expected_lets = [
      {type: :let!, name: :bang_value, line: 20},
      {type: :let, name: :computed_value, line: 21},
      {type: :let, name: :simple_value, line: 22},
      {type: :let, name: :context_value, line: 25},
      {type: :let, name: :mutable_array, line: 45}
    ]

    expected_lets.each_with_index do |expected, index|
      let = lets[index]
      assert_equal expected[:type], let[:type]
      assert_equal expected[:name], let[:name]
      assert_equal expected[:line], let[:line]
    end
  end

  def test_find_lets_in_empty_file
    Tempfile.create("empty_spec.rb") do |temp_file|
      File.write(temp_file, "# Empty spec file")
      analyzer = BeLetItBe::Analyzer.new(temp_file.path)
      lets = analyzer.find_lets
      assert_empty lets
    end
  end
end
