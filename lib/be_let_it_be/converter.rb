# frozen_string_literal: true

require "prism"
require "tempfile"

module BeLetItBe
  class Converter
    def initialize(file)
      @file = file.respond_to?(:path) ? file.path : file
    end

    def try_conversion_single_let(let_info, output_file, exam)
      source = File.read(@file)

      File.write(output_file, apply_single_conversion(let_info, source))

      passed = exam.call
      unless passed
        File.write(output_file, source) # revert changes
      end
      passed
    end

    private

    def apply_single_conversion(let_info, source)
      node = let_info[:node]

      start_offset = node.message_loc.start_offset
      end_offset = node.message_loc.end_offset

      new_source = source.dup
      new_source[start_offset...end_offset] = "let_it_be"

      new_source
    end
  end
end
