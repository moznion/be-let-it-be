# frozen_string_literal: true

require_relative "lib/be_let_it_be/version"

Gem::Specification.new do |spec|
  spec.name = "be-let-it-be"
  spec.version = BeLetItBe::VERSION
  spec.authors = ["moznion"]
  spec.email = ["moznion@mail.moznion.net"]

  spec.summary = "Convert RSpec let/let! to let_it_be where possible"
  spec.description = "A command-line tool that analyzes RSpec files and converts let/let! to let_it_be where tests still pass"
  spec.homepage = "https://github.com/moznion/be-let-it-be"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/moznion/be-let-it-be"
  spec.metadata["changelog_uri"] = "https://github.com/moznion/be-let-it-be/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "bin"
  spec.executables = ["be-let-it-be"]
  spec.require_paths = ["lib"]

  spec.add_dependency "parser", "~> 3.3"
  spec.add_dependency "unparser", "~> 0.7"
  spec.add_dependency "thor", "~> 1.3"
end
