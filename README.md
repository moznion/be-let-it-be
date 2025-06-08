# be-let-it-be

A command-line tool that automatically converts RSpec's `let` and `let!` declarations to `let_it_be` where it's safe to do so. The tool runs your tests after each conversion to ensure they still pass, making the optimization process safe and reliable.

## Motivation

One of the main motivations is to improve test speed.

### What is `let_it_be`?

`let_it_be` is a helper provided by the [test-prof](https://github.com/test-prof/test-prof) gem that caches test data across examples instead of recreating it for each test. This can significantly improve test performance, especially for expensive object creation like database records.

### Performance Benefits

Using `let_it_be` can significantly improve test performance by:

- Reducing database queries
- Minimizing object instantiation overhead
- Sharing immutable test data across examples

Performance gains are especially noticeable with:

- Factory-created database records
- Complex object initialization
- Large test suites

## How It Works

1. Parse: Analyzes your RSpec file using Ruby's Abstract Syntax Tree
2. Identify: Finds all `let` and `let!` declarations
3. Convert & Test: For each declaration:
  - Converts it to `let_it_be`
  - Runs your tests
  - Keeps the change if tests pass, reverts if they fail
4. Save: Writes the successfully converted file, or it outputs the result if it's in dryrun mode

## Example Conversion

Before:

```ruby
RSpec.describe User do
  let!(:admin) { create(:user, admin: true) }
  let(:user) { create(:user) }
  let(:posts) { user.posts }
  let(:mutable_array) { [] }

  it "modifies the array" do
    mutable_array << 1
    expect(mutable_array).to eq([1])
  end
end
```

After:

```ruby
RSpec.describe User do
  let_it_be(:admin) { create(:user, admin: true) }
  let_it_be(:user) { create(:user) }
  let(:posts) { user.posts }  # Kept as 'let' due to dependency
  let(:mutable_array) { [] }  # Kept as 'let' because tests modify it

  it "modifies the array" do
    mutable_array << 1
    expect(mutable_array).to eq([1])
  end
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
group :development, :test do
  gem 'be_let_it_be'
end
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install be_let_it_be
```

## Prerequisites

- Ruby 3.3.0 or higher
- Your project must have [test-prof](https://github.com/test-prof/test-prof) installed, as `let_it_be` is a feature provided by that gem

## Usage

### Basic Usage

Convert a single spec file:

```bash
bundle exec be-let-it-be convert spec/models/user_spec.rb
```

### Options

- `--dryrun` - Show what would be converted without making actual changes
- `--verbose` - Display detailed processing information
- `--rspec_cmd` - Customize the RSpec command used for verification (default: "rspec")

### Examples

```bash
# Dry-run to preview changes
bundle exec be-let-it-be convert spec/models/user_spec.rb --dryrun

# Verbose output for debugging
bundle exec be-let-it-be convert spec/models/user_spec.rb --verbose

# Use custom RSpec command
bundle exec be-let-it-be convert spec/models/user_spec.rb --rspec_cmd="rspec --format progress"
```

## When NOT to Use `let_it_be`

The tool automatically detects when conversions would break tests, but it's good to understand when `let_it_be` isn't appropriate:

- Mutable objects: When tests modify the object state
- Test-specific state: When the value depends on test-specific setup
- Fresh instances: When each test requires a completely new instance

## Current Limitations

- Originally, the replacement of `let` and `let!` should adopt the combination that provides the most optimized execution time. However, attempting to do so would likely cause combinatorial explosion, making it non-trivial to implement. Therefore, we currently use a simple approach of replacing them in order of appearance. We plan to address this optimization in the future.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/moznion/be_let_it_be. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/moznion/be_let_it_be/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the be_let_it_be project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/moznion/be_let_it_be/blob/main/CODE_OF_CONDUCT.md).

