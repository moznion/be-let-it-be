# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "be_let_it_be"

require "minitest/autorun"

def fixture_path(filename)
  File.join(__dir__, "fixtures", filename)
end
