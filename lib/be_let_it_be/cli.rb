# frozen_string_literal: true

require "thor"
require "open3"

module BeLetItBe
  class CLI < Thor
    desc "convert FILE", "Convert let/let! to let_it_be in RSpec file"
    option :dryrun, type: :boolean, default: false, desc: "Show what would be converted without modifying files"
    option :verbose, type: :boolean, default: false, desc: "Show the processing output verboselly"
    option :rspec_cmd, type: :string, default: "bundle exec rspec", desc: "RSpec command to check the behaviour"
    option :dryrun_exit_code, type: :numeric, default: 1, desc: "Exit code to use in dryrun mode when any convertible declarations are present"

    def convert(file)
      @processed_let_lines = []

      unless File.exist?(file)
        error "File not found: #{file}"
        exit 1
      end

      unless run_rspec(file)
        error "Initial RSpec test failed. Aborting."
        exit 1
      end
      say "Initial tests passed. Starting conversion..."

      temp_file = file + ".temp"
      begin
        File.write(temp_file, File.read(file))

        processed_num = 0
        converted_count = 0
        lets = extract_let_info(file)
        num_of_lets = lets.length

        if num_of_lets.zero?
          say "✨ no let/let! in the given spec; do nothing"
          exit 0
        end

        say "Found #{num_of_lets} let/let! definitions:"
        lets.each { |let| say "  - #{let[:type]} :#{let[:name]} at #{file}:#{let[:line]}" }

        until lets.empty?
          processed_num += 1
          converter = Converter.new(temp_file)
          let = lets.first

          say "[#{processed_num}/#{num_of_lets}] Testing conversion of #{let[:type]} :#{let[:name]} at #{file}:#{let[:line]}"

          if converter.try_conversion_single_let(let, temp_file, -> { run_rspec(temp_file) })
            say "  ✅ Converted to let_it_be"
            converter = Converter.new(temp_file) # pile the converted items
            converted_count += 1
          else
            say "  ❌ Keeping original #{let[:type]} (test failed with let_it_be)"
          end

          @processed_let_lines << let[:line]
          lets = extract_let_info(temp_file)
        end

        if converted_count > 0
          say "🚀 Successfully converted #{converted_count} out of #{lets.size} definitions to let_it_be"

          if options[:dryrun]
            puts File.read(temp_file)
            exit options[:dryrun_exit_code]
          else
            File.write(file, File.read(temp_file))
          end
        else
          say "❣️ No conversions were possible (all tests failed with let_it_be)"
        end
      ensure
        File.unlink(temp_file) if File.exist?(temp_file)
      end
    end

    private

    def extract_let_info(file)
      analyzer = Analyzer.new(file)
      lets = analyzer.find_lets

      lets.filter { |l| !@processed_let_lines.include?(l[:line]) }
    end

    def say(msg)
      return unless options[:verbose]

      puts msg
    end

    def run_rspec(file)
      cmd = "#{options[:rspec_cmd]} #{file}"
      say "Running: #{cmd}"

      stdout, stderr, status = Open3.capture3(cmd)

      say "RSpec output:"
      say stdout
      say stderr if stderr && !stderr.empty?

      status.success?
    end
  end
end
