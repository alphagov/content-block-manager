# :nocov:

# Taken from https://github.com/alphagov/collections/blob/53f903ab6499c63fb8889e4aab8ee4e7c8e384a7/lib/parsers/convert_to_rspec.rb
# - Taken from https://gist.github.com/seven1m/e375bcdf2864da0022f1

require "parser/current"
require "unparser"
require "fileutils"

module Parsers
  class ConvertToRspec
    attr_reader :minitest_folder, :rspec_folder

    def initialize(minitest_folder, rspec_folder)
      @minitest_folder = minitest_folder
      @rspec_folder = rspec_folder
    end

    def go!
      Dir["#{minitest_folder}/*_test.rb"].each do |test|
        puts test
        body = File.read(test)
        test.gsub!(minitest_folder.to_s, rspec_folder.to_s)
        new_path = test.gsub!(/_test\.rb$/, "_spec.rb")

        body = remove_test_helper(body)
        body = remove_minitest_require(body)

        class_to_rspec_describe!(body)
        component_class_to_rspec_describe!(body)
        integration_test_to_rspec_describe!(body)
        assert_selector_to_expect!(body)
        class_name_to_described_class!(body)
        stubbed_method_to_allow!(body)
        stubbed_method_at_least_once_to_allow!(body)
        mock_to_double!(body)
        stub_to_double!(body)
        allow_any_instance!(body)
        class_expects_to_expect_class!(body)
        returns_to_and_return!(body)
        at_least_once!(body)

        before!(body)
        context_to_describe!(body)
        test_to_it!(body)
        assert_question!(body)
        assert_cannot!(body)
        assert_can!(body)
        assert_equal!(body)
        assert_empty!(body)
        assert_include!(body)
        assert_match!(body)
        assert_response!(body)
        assert_redirected_to!(body)
        assert_nil!(body)
        assert_not!(body)
        assert!(body)

        body = trim_body(body)
        FileUtils.mkdir_p(rspec_folder)
        File.open(new_path, "w") { |f| f.write(body) }
      end
    end

    def trim_body(body)
      "#{body.strip}\n"
    end

    def remove_test_helper(body)
      body.gsub(/require "test_helper"(\n)+/, "")
    end

    def remove_minitest_require(body)
      body.gsub(/\n\s*extend Minitest::Spec::DSL\n/, "\n")
    end

    def returns_to_and_return!(body)
      replace_line!(body) do |line|
        if line =~ /^(.*)\.returns\((.*)$/
          "#{Regexp.last_match(1)}.and_return(#{Regexp.last_match(2)}"
        end
      end
    end

    def class_expects_to_expect_class!(body)
      replace_line!(body) do |line|
        if line =~ /^(\s*)([:\w]+)\.expects\((.*)$/
          "#{Regexp.last_match(1)}expect(#{Regexp.last_match(2)}).to receive(#{Regexp.last_match(3)}"
        end
      end
    end

    def allow_any_instance!(body)
      replace_line!(body) do |line|
        if line =~ /(\s*)allow\((.*).any_instance\).to(.*)/
          "#{Regexp.last_match(1)}allow_any_instance_of(#{Regexp.last_match(2)}).to#{Regexp.last_match(3)}"
        end
      end
    end

    def mock_to_double!(body)
      replace_line!(body) do |line|
        if line =~ /(.*) mock(\s*)(.*)/
          "#{Regexp.last_match(1)} double#{Regexp.last_match(2)}#{Regexp.last_match(3)}"
        end
      end
    end

    def stub_to_double!(body)
      replace_line!(body) do |line|
        if line =~ /(.*)\bstub\b(.*)/
          "#{Regexp.last_match(1)}double#{Regexp.last_match(2)}"
        end
      end
    end

    def stubbed_method_to_allow!(body)
      replace_line!(body) do |line|
        if line =~ /(\s*)(.*)?.stubs\((.*)?\).returns\((.*)/
          "#{Regexp.last_match(1)}allow(#{Regexp.last_match(2)}).to receive(#{Regexp.last_match(3)}).and_return(#{Regexp.last_match(4)}"
        end
      end
    end

    def stubbed_method_at_least_once_to_allow!(body)
      replace_line!(body) do |line|
        if line =~ /(\s*)(.*)\.stubs\((.*)\).at_least_once(.*)/
          "#{Regexp.last_match(1)}expect(#{Regexp.last_match(2)}).to receive(#{Regexp.last_match(3)}).at_least(:once)#{Regexp.last_match(4)}"
        end
      end
    end

    def class_name_to_described_class!(body)
      if body =~ /RSpec\.describe ([:\w]+)?,/
        class_name = body.match(/RSpec\.describe ([:\w]+),/).captures.first
        replace_line!(body) do |line|
          if line =~ /(.*)#{class_name}\.(.*)/
            "#{Regexp.last_match(1)}described_class.#{Regexp.last_match(2)}"
          end
        end
      end
    end

    def component_class_to_rspec_describe!(body)
      replace_line!(body) do |line|
        if line =~ /class ([:\w]+)Test < ViewComponent::TestCase\s*$/
          "RSpec.describe #{Regexp.last_match(1)}, type: :component do"
        end
      end
    end

    def integration_test_to_rspec_describe!(body)
      replace_line!(body) do |line|
        if line =~ /class ([:\w]+)Test < ActionDispatch::IntegrationTest\s*$/
          "RSpec.describe #{Regexp.last_match(1)}, type: :integration do"
        end
      end
    end

    def class_to_rspec_describe!(body)
      replace_line!(body) do |line|
        if line =~ /class ([:\w]+)Test < ActiveSupport::TestCase\s*$/
          "RSpec.describe #{Regexp.last_match(1)} do"
        end
      end
    end

    def assert_selector_to_expect!(body)
      replace_line!(body) do |line|
        if line =~ /(\s*)assert_selector (.*)$/
          "#{Regexp.last_match(1)}expect(page).to have_css #{Regexp.last_match(2)}"
        end
      end
    end

    def before!(body)
      replace_line!(body) do |line|
        if line =~ /(\s*)(setup do|def setup)/
          "#{Regexp.last_match(1)}before do"
        end
      end
    end

    def context_to_describe!(body)
      replace_line!(body) do |line|
        if line =~ /^(\s*)context (['"])(\w+)(['"]) do\s*$/
          "#{Regexp.last_match(1)}describe #{Regexp.last_match(2)}#{Regexp.last_match(3)}#{Regexp.last_match(4)} do"
        end
      end
    end

    def test_to_it!(body)
      replace_line!(body) do |line|
        if line =~ /^(\s*)test (['"])(.*)(['"]) do\s*$/
          "#{Regexp.last_match(1)}it #{Regexp.last_match(2)}#{Regexp.last_match(3)}#{Regexp.last_match(4)} do"
        end
      end
    end

    def at_least_once!(body)
      replace_line!(body) do |line|
        if line =~ /(\s*)(.*)\.at_least_once(.*)/
          "#{Regexp.last_match(1)}#{Regexp.last_match(2)}.at_least(:once)#{Regexp.last_match(3)}"
        end
      end
    end

    def assert_question!(body)
      replace_line!(body) do |line|
        if line =~ /^(\s*)assert (!|not )(.*)\.(\w+)\?\s*$/
          "#{Regexp.last_match(1)}expect(#{Regexp.last_match(3)}).to_not be_#{Regexp.last_match(4)}"
        elsif line =~ /^(\s*)assert (.*)\.(\w+)\?\s*$/
          "#{Regexp.last_match(1)}expect(#{Regexp.last_match(2)}).to be_#{Regexp.last_match(3)}"
        end
      end
    end

    def assert_equal!(body)
      body.gsub!(/assert_equal(.*),\s*\n(.*)$/, "assert_equal\\1, \\2")
      replace_line!(body) do |line|
        if line =~ /^(\s*)(assert_equal.*)$/
          (arg1, arg2) = get_args(line)
          "#{Regexp.last_match(1)}expect(#{arg2}).to eq(#{arg1})"
        end
      end
    end

    def assert_cannot!(body)
      replace_line!(body) do |line|
        if line =~ /^(\s*)(assert_cannot.*)$/
          (arg1, arg2, arg3) = get_args(line)
          "#{Regexp.last_match(1)}expect(#{arg1}).to_not be_able_to(#{arg2}, #{arg3})"
        end
      end
    end

    def assert_can!(body)
      replace_line!(body) do |line|
        if line =~ /^(\s*)(assert_can.*)$/
          (arg1, arg2, arg3) = get_args(line)
          "#{Regexp.last_match(1)}expect(#{arg1}).to be_able_to(#{arg2}, #{arg3})"
        end
      end
    end

    def assert_include!(body)
      replace_line!(body) do |line|
        if line =~ /^(\s*)assert (!|not )?(.*)\.include\?\((.*)\)$/
          negate = Regexp.last_match(2) ? "_not" : ""
          "#{Regexp.last_match(1)}expect(#{Regexp.last_match(3)}).to#{negate} include(#{Regexp.last_match(4)})"
        end
      end
    end

    def assert_match!(body)
      body.gsub!(/assert_match(.*),\s*\n(.*)$/, "assert_match\\1, \\2")
      replace_line!(body) do |line|
        if line =~ /^(\s*)(assert_match.*)$/
          (arg1, arg2) = get_args(line)
          "#{Regexp.last_match(1)}expect(#{arg2}).to match(#{arg1})"
        end
      end
    end

    def assert_response!(body)
      replace_line!(body) do |line|
        if line =~ /^(\s*)assert_response :(.*)$/
          "#{Regexp.last_match(1)}expect(response).to be_#{Regexp.last_match(2)}"
        end
      end
    end

    def assert_redirected_to!(body)
      replace_line!(body) do |line|
        if line =~ /^(\s*)assert_redirected_to (.*)$/
          "#{Regexp.last_match(1)}expect(response).to redirect_to(#{Regexp.last_match(2)})"
        end
      end
    end

    def assert_nil!(body)
      replace_line!(body) do |line|
        if line =~ /^(\s*)assert_nil (.*)$/
          "#{Regexp.last_match(1)}expect(#{Regexp.last_match(2)}).to be_nil"
        end
      end
    end

    def assert_empty!(body)
      replace_line!(body) do |line|
        if line =~ /^(\s*)assert_empty (.*)$/
          "#{Regexp.last_match(1)}expect(#{Regexp.last_match(2)}).to be_empty"
        end
      end
    end

    def assert_not!(body)
      replace_line!(body) do |line|
        if line =~ /^(\s*)assert (!|not )(.*)\s*$/
          "#{Regexp.last_match(1)}expect(#{Regexp.last_match(3)}).not_to be"
        end
      end
    end

    def assert!(body)
      replace_line!(body) do |line|
        if line =~ /^(\s*)assert (.*)\s*$/
          "#{Regexp.last_match(1)}expect(#{Regexp.last_match(2)}).to be"
        end
      end
    end

    def replace_line!(body)
      lines = body.split(/\n/)
      lines.each_with_index do |line, index|
        begin
          new_line = yield(line, index)
        rescue StandardError
          puts "----------------------------------------"
          puts "line number #{index + 1}:"
          puts line.strip
          puts "----------------------------------------"
          # GCM: I've commented this out because I'd rather have the converter continue to process the file
          # than just exit on the first parsing error.
          # raise
        end
        lines[index] = new_line if new_line
      end
      body.replace(lines.join("\n"))
    end

    def get_args(line)
      ast = Parser::CurrentRuby.parse(line)
      args = ast.to_a[2..]
      args.map { |a| Unparser.unparse(a) }
    end
  end
end
# :nocov:
