# frozen_string_literal: true

require "parser/current"
require "unparser"
require "tempfile"

module BeLetItBe
  class Converter
    def initialize(file)
      @file = file
    end

    def try_conversion_single_let(let_info, output_file, exam)
      source = File.read(@file)
      buffer = Parser::Source::Buffer.new(@file, source:)

      temp_rewriter = Parser::Source::TreeRewriter.new(buffer)
      apply_single_conversion(let_info, temp_rewriter)
      File.write(output_file, temp_rewriter.process)

      passed = exam.call
      unless passed
        File.write(output_file, source) # revert changes
      end
      passed
    end

    private

    def apply_single_conversion(let_info, rewriter)
      node = let_info[:node]
      method_range = node.loc.selector

      rewriter.replace(method_range, "let_it_be")
    end
  end
end
