# frozen_string_literal: true

require "test_helper"

class TestBeLetItBe < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::BeLetItBe::VERSION
  end

  def test_constants_are_loaded
    assert defined?(BeLetItBe::CLI)
    assert defined?(BeLetItBe::Analyzer)
    assert defined?(BeLetItBe::Converter)
  end
end
