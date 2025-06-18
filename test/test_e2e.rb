# frozen_string_literal: true

require "bundler"
require "test_helper"

class TestE2E < Minitest::Test
  EXPECTED_OUTPUT = <<~OUTPUT
    # frozen_string_literal: true

    require "test_prof/recipes/rspec/before_all"
    require "test_prof/recipes/rspec/let_it_be"

    class TestProfDummyAdapter
      def begin_transaction
      end

      def rollback_transaction
      end

      def commit_transaction
      end
    end

    TestProf::BeforeAll.adapter = TestProfDummyAdapter.new

    RSpec.describe "Sample" do
      let_it_be(:bang_value) { "important" }
      let(:computed_value) { simple_value * 2 }
      let_it_be(:simple_value) { 42 }

      context "when testing" do
        let_it_be(:context_value) { "context specific" }

        it "uses simple_value" do
          expect(simple_value).to eq(42)
        end

        it "uses bang_value" do
          expect(bang_value).to eq("important")
        end

        it "uses computed_value" do
          expect(computed_value).to eq(84)
        end

        it "uses context_value" do
          expect(context_value).to eq("context specific")
        end
      end

      context "when value is mutable" do
        let(:mutable_array) { [] }

        it "can modify the array" do
          mutable_array << 1
          expect(mutable_array).to eq([1])
        end

        it "starts fresh in each test" do
          expect(mutable_array).to eq([])
        end
      end
    end
  OUTPUT

  private_constant :EXPECTED_OUTPUT

  def test_e2e
    File.write(fixture_path("sample_spec.rb.dup"), File.read(fixture_path("sample_spec.rb")))

    cmd = "#{File.join(Bundler.root.to_s, "bin", "be-let-it-be")} convert #{fixture_path("sample_spec.rb.dup")}"
    _, _, status = Open3.capture3(cmd)
    assert_equal 0, status.exitstatus

    assert_equal EXPECTED_OUTPUT, File.read(fixture_path("sample_spec.rb.dup"))
  ensure
    File.unlink(fixture_path("sample_spec.rb.dup")) if File.exist?(fixture_path("sample_spec.rb.dup"))
  end

  def test_e2e_dryrun
    cmd = "#{File.join(Bundler.root.to_s, "bin", "be-let-it-be")} convert --dryrun #{fixture_path("sample_spec.rb")}"
    stdout, _, status = Open3.capture3(cmd)

    assert_equal EXPECTED_OUTPUT, stdout
    assert_equal 1, status.exitstatus
  end

  def test_e2e_dryrun_with_custom_exit_code
    cmd = "#{File.join(Bundler.root.to_s, "bin", "be-let-it-be")} convert --dryrun --dryrun-exit-code 2 #{fixture_path("sample_spec.rb")}"
    stdout, _, status = Open3.capture3(cmd)

    assert_equal EXPECTED_OUTPUT, stdout
    assert_equal 2, status.exitstatus
  end

  def test_e2e_dryrun_no_conversions_possible
    cmd = "#{File.join(Bundler.root.to_s, "bin", "be-let-it-be")} convert --dryrun #{fixture_path("no_convertible_spec.rb")}"
    stdout, _, status = Open3.capture3(cmd)

    assert_equal "", stdout
    assert_equal 0, status.exitstatus
  end
end
