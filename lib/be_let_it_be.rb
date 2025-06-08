# frozen_string_literal: true

require_relative "be_let_it_be/version"
require_relative "be_let_it_be/cli"
require_relative "be_let_it_be/analyzer"
require_relative "be_let_it_be/converter"

module BeLetItBe
  class Error < StandardError; end
end
